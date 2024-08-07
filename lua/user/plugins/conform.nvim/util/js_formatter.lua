local user = require "user"
local workspace = require "user.config.workspace"
local fs_util = require "user.util.fs"

local M = {}

---@param pwd string
local function check_eslint_activated_under_path(pwd)
    local target = pwd .. "/.eslintrc.*"
    local matsh_str = vim.fn.glob(target)
    if matsh_str ~= "" then
        return true
    end

    local file = io.open(pwd .. "/package.json", "r")
    if file then
        local content = file:read("*a")
        local parse_ok, value = pcall(vim.json.decode, content)

        if parse_ok
            and type(value) == "table"
            and value.eslintConfig ~= nil
        then
            return true
        end
    end

    return false
end

---@return boolean
local function check_eslint_activated()
    local pwd = workspace.get_workspace_path()
    local paths = { pwd }
    for _, path in user.workspace.sub_directories:ipairs() do
        paths[#paths + 1] = fs_util.path_join(pwd, path)
    end

    local ok = true
    for _, path in ipairs(paths) do
        ok = check_eslint_activated_under_path(path)
        if ok then
            break
        end
    end

    return ok
end

local formatters = {
    --[[ {
        name = "prettierd",
        check_cache = nil,
        check_available = function(info)
            local cached = info.check_cache
            if cached ~= nil then
                return cached
            end

            local ok = check_eslint_activated()
            info.check_cache = ok
            return ok
        end,
    }, ]]
    {
        name = "eslint_d",
        check_cache = nil,
        check_available = function(info)
            local cached = info.check_cache
            if cached ~= nil then
                return cached
            end

            local ok = check_eslint_activated()
            info.check_cache = ok
            return ok
        end,
    }
}

---@return string[]
function M.get_formatters()
    local result = {}
    for _, info in ipairs(formatters) do
        if info.check_available(info) then
            result[#result + 1] = info.name
        end
    end

    return result
end

return M
