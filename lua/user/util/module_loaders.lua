local PATH_SEP = vim.fn.has("WIN32") == 1 and "\\" or "/"

local initialized = false

local M = {}
M.user_runtime_path = nil

---@param path string
---@return string
local function path_name_digest(path)
    local name = path

    local len = #name
    local max_len = 45
    if len > max_len then
        name = "..." .. name:sub(len - max_len + 1)
    end

    return name
end

-- byte code loader
local function byte_code_loader(original_modulename)
    local substr = original_modulename:sub(1, 5)
    if substr ~= "user." and substr ~= "user/" then
        return "\n\tnot a user config module (user config byte code loader)"
    end

    local modulename = original_modulename:sub(6)
    if vim.endswith(modulename, ".lua") then
        modulename = modulename:sub(1, #modulename - 4) .. ".luac"
    end
    modulename = "user-build/" .. modulename

    local user_runtime_path = M.user_runtime_path

    local errmsg = { "" }
    local err_template = "no file '%s' (user config byte code loader)"

    local paths = {
        vim.fs.joinpath(user_runtime_path, modulename .. ".luac"),
        vim.fs.joinpath(user_runtime_path, modulename, "init.luac"),
    }

    modulename = modulename:gsub("%.", PATH_SEP)
    vim.list_extend(paths, {
        vim.fs.joinpath(user_runtime_path, modulename .. ".luac"),
        vim.fs.joinpath(user_runtime_path, modulename, "init.luac"),
    })

    for i = 1, #paths do
        local path = paths[i]
        local file = io.open(path, "rb")
        if file then
            local content = assert(file:read("*a"))
            local chunkname = path_name_digest(path)
            return assert(loadstring(content, chunkname))
        end
        table.insert(errmsg, err_template:format(path))
    end

    return table.concat(errmsg, "\n\t")
end

---@type (fun(modulename: string): string | function)[]
local loaders = {
    -- no_dot_substiting_loader
    function(modulename)
        local errmsg = { "" }
        local err_template = "no file '%s' (no dot-sub loader)"

        for path in string.gmatch(package.path, "([^;]+)") do
            local filename = string.gsub(path, "%?", modulename)
            local file = io.open(filename, "rb")
            if file then
                local content = assert(file:read("*a"))
                local chunkname = path_name_digest(filename)
                return assert(loadstring(content, chunkname))
            end
            table.insert(errmsg, err_template:format(filename))
        end

        return table.concat(errmsg, "\n\t")
    end,
    -- plugin_config_loader
    function(modulename)
        local substr = modulename:sub(1, 5)
        if substr ~= "user." and substr ~= "user/" then
            return "\n\tnot a plugin config module (plugin config loader)"
        end

        local user_runtime_path = M.user_runtime_path

        local errmsg = { "" }
        local err_template = "no file '%s' (plugin config loader)"

        local paths = {
            vim.fs.joinpath(user_runtime_path, modulename .. ".lua"),
            vim.fs.joinpath(user_runtime_path, modulename, "init.lua"),
        }

        for i = 1, #paths do
            local path = paths[i]
            local file = io.open(path, "rb")
            if file then
                local content = assert(file:read("*a"))
                local chunkname = path_name_digest(path)
                return assert(loadstring(content, chunkname))
            end
            table.insert(errmsg, err_template:format(path))
        end

        return table.concat(errmsg, "\n\t")
    end,
    -- workspace_loader
    function(raw_modulename)
        local workspace = require "user.config.workspace"

        local dirname = workspace.WORKSPACE_CONFIG_DIR_NAME
        if raw_modulename:sub(1, #dirname) ~= dirname then
            return "\n\tnot a module under .nvim directory (workspace loader)"
        end

        local errmsg = { "" }
        local err_template = "no file '%s' (workspace loader)"

        local modulename = raw_modulename:gsub("%.", PATH_SEP)
        do
            local temp = dirname:gsub("%.", PATH_SEP)
            modulename = dirname .. modulename:sub(#temp + 1)
        end

        local workspace_path = workspace.get_workspace_path()
        local paths = {
            vim.fs.joinpath(workspace_path, modulename),
            vim.fs.joinpath(workspace_path, modulename .. ".lua"),
            vim.fs.joinpath(workspace_path, modulename, "init.lua"),
        }

        for i = 1, #paths do
            local path = paths[i]
            local file = io.open(path, "rb")
            if file then
                local chunkname = path_name_digest(path)
                return assert(loadstring(assert(file:read("*a")), chunkname))
            end
            table.insert(errmsg, err_template:format(path))
        end

        return table.concat(errmsg, "\n\t")
    end,
}

---@class user.ModuleLoaderOptions
---@field enable_byte_code? boolean
---@field user_runtime_path string

---@param options user.ModuleLoaderOptions
function M.init(options)
    if initialized then return end

    initialized = true

    -- allow loading modules via absolute path
    package.path = package.path .. ";?.lua;?/init.lua"

    M.user_runtime_path = options.user_runtime_path

    if options.enable_byte_code then
        table.insert(package.loaders, 1, byte_code_loader)
    end

    for _, loader in ipairs(loaders) do
        table.insert(package.loaders, loader)
    end
end

return M
