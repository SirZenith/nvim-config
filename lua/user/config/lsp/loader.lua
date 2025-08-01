local fs = vim.fs
local fnamemodify = vim.fn.fnamemodify

local M = {}

---@param module_name string
---@return string[]
local function get_config_module_paths(module_name)
    return {
        fnamemodify(module_name, ":p"),
        fnamemodify(module_name .. ".lua", ":p"),
        fnamemodify(module_name .. "/init.lua", ":p"),
    }
end

-- load module with absolute path
local function require_absolute(module_name)
    local errmsg = { "" }
    local err_template = "no file '%s'"

    local paths = get_config_module_paths(module_name)

    for _, filename in ipairs(paths) do
        if vim.fn.filereadable(filename) == 1 then
            local file = io.open(filename, "rb")
            if file then
                local content = assert(file:read("*a"))
                return assert(loadstring(content, filename))
            end
        end
        table.insert(errmsg, err_template:format(filename))
    end

    error(table.concat(errmsg, "\n\t"))
end

---@param module_name string
---@return boolean
local function check_config_module_exists(module_name)
    local paths = get_config_module_paths(module_name)
    local ok = false
    for _, path in ipairs(paths) do
        if vim.fn.filereadable(path) == 1 then
            ok = true
            break
        end
    end
    return ok
end

-- Try to find config file for given language server in user config directory.
---@param root_path string
---@param ls_name string
---@return table
function M.load(root_path, ls_name)
    local module_name = fs.normalize(root_path) .. "/" .. ls_name

    if not check_config_module_exists(module_name) then
        return {}
    end

    local ok, module = xpcall(
        require_absolute,
        function(err)
            local traceback = debug.traceback(err)
            vim.notify(traceback or err, vim.log.levels.WARN)
        end,
        module_name
    )

    local user_config
    if ok then
        user_config = module()
    else
        user_config = {}
    end

    return user_config
end

return M
