local fs = require "user.utils.fs"
local workspace = require "user.workspace"

local M = {}
M.config_home = nil

M.loaders = {
    ---@param modulename string
    no_dot_substiting_loader = function(modulename)
        local errmsg = ""
        local err_template = "%s\n\tno file '%s' (no dot-sub loader)"

        for path in string.gmatch(package.path, "([^;]+)") do
            local filename = string.gsub(path, "%?", modulename)
            local file = io.open(filename, "rb")
            if file then
                local content = assert(file:read("*a"))
                return assert(loadstring(content, filename))
            end
            errmsg = err_template:format(errmsg, path)
        end
        return errmsg
    end,

    ---@param modulename string
    plugin_config_loader = function(modulename)
        local config_home = M.config_home

        local errmsg = ""
        local err_template = "%s\n\tno file '%s' (plugin config loader)"

        local paths = {
            fs.path_join(modulename),
            fs.path_join(config_home, modulename),
            fs.path_join(config_home, modulename .. ".lua"),
            fs.path_join(config_home, modulename, "init.lua"),
        }

        for i = 1, #paths do
            local path = paths[i]
            local file = io.open(path, "rb")
            if file then
                local content = assert(file:read("*a"))
                return assert(loadstring(content, path))
            end
            errmsg = err_template:format(errmsg, path)
        end

        return errmsg
    end,

    ---@param raw_modulename string
    workspace_loader = function(raw_modulename)
        local dirname = workspace.WORKSPACE_CONFIG_DIR_NAME
        if raw_modulename:sub(1, #dirname) ~= dirname then
            return "\n\tworkspace loader only works for modules under .nvim namespace."
        end

        local errmsg = ""
        local err_template = "%s\n\tno file '%s' (workspace loader)"

        local modulename = raw_modulename:gsub("%.", fs.PATH_SEP)
        do
            local temp = dirname:gsub("%.", fs.PATH_SEP)
            modulename = dirname .. modulename:sub(#temp + 1)
        end

        local workspace_path = workspace.get_workspace_path()
        local paths = {
            fs.path_join(workspace_path, modulename),
            fs.path_join(workspace_path, modulename .. ".lua"),
            fs.path_join(workspace_path, modulename, "init.lua"),
        }

        for i = 1, #paths do
            local path = paths[i]
            local file = io.open(path, "rb")
            if file then
                return assert(loadstring(assert(file:read("*a")), path))
            end
            errmsg = err_template:format(errmsg, path)
        end

        return errmsg
    end,
}

function M.setup(options)
    M.config_home = options.config_home

    for _, loader in pairs(M.loaders) do
        table.insert(package.loaders, loader)
    end
end

return M
