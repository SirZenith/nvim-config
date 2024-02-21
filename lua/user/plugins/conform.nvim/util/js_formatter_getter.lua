local workspace = require "user.config.workspace"

local M = {}

local formatters = {
    {
        name = "prettier_d_slim",
        check_cache = nil,
        check_available = function(info)
            local cached = info.check_cache
            if cached ~= nil then
                return cached
            end

            local ok = true
            info.check_cache = ok
            return ok
        end,
    },
    {
        name = "eslint_d",
        check_cache = nil,
        check_available = function(info)
            local cached = info.check_cache
            if cached ~= nil then
                return cached
            end

            local ok = false

            local pwd = workspace.get_workspace_path()
            local target = pwd .. "/.eslintrc.*"
            local matsh_str = vim.fn.glob(target)
            if matsh_str ~= "" then
                ok = true
            end

            if not ok then
                local file = io.open(pwd .. "/package.json", "r")
                if file then
                    local content = file:read("*a")
                    local parse_ok, value = pcall(vim.json.decode, content)
                    if parse_ok
                        and type(value) == "table"
                        and value.eslintConfig ~= nil
                    then
                        ok = true
                    end
                end
            end

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
            vim.print(info.name, "is available")
            result[#result + 1] = info.name
        end
    end

    return result
end

return M
