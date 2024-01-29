local user = require "user"
local fs = require "user.utils.fs"
local functional = require "user.utils.functional"
local table_utils = require "user.utils.table"
local workspace = require "user.workspace"

local M = {}

local function get_import_paths(is_in_nvim_runtime_path)
    local paths = {}

    -- NeoVim Runtime Path
    if is_in_nvim_runtime_path then
        local patterns = {
            "nvim/runtime",
        }

        local list = vim.api.nvim_list_runtime_paths()

        for i = 1, #list do
            local path = vim.fs.normalize(list[i])

            for j = 1, #patterns do
                local patt = patterns[j]
                if path:match(patt) then
                    paths[#paths + 1] = path
                end
            end
        end
    end

    -- Plugin Main Path
    -- Used when editing user config.
    local workspace_path = workspace.get_workspace_path()
    if fs.is_subdir_of(workspace_path, user.env.NVIM_HOME()) then
        local plugin_root = fs.path_join(vim.fn.stdpath("data"), "lazy")
        local plugins = {
            "cmd-snippet",
            "LuaSnip",#
            "noice.nvim",
            "nvim-cmp",
            "nvim-lspconfig",
            "mongosh.nvim",
            "panelpal.nvim",
            "snippet-loader",
        }
        for i = 1, #plugins do
            local name = plugins[i]
            paths[#paths + 1] = fs.path_join(plugin_root, name, "lua")
        end
    end

    -- Lua import Path
    for _, path in ipairs(vim.split(package.path, ";")) do
        path = vim.fs.normalize(path)

        if path:ends_with("?.lua") then
            path = path:sub(1, -6)
        elseif path:ends_with("?/init.lua") then
            path = path:sub(1, -11)
        end

        if path:ends_with("/") then
            path = path:sub(1, -2)
        end

        paths[#paths + 1] = path
    end

    for i = 1, #paths do
        paths[i] = vim.fs.normalize(paths[i])
    end

    paths = table_utils.remove_duplicates(paths)

    return paths
end

-- path list for looking for required module.
-- pathes that are not in current workspace need also be presenting in
-- workspace.library setting to enable loading definition from those paths
local function get_runtime_paths(is_in_nvim_runtime_path)
    local import_paths = get_import_paths(is_in_nvim_runtime_path)

    local paths = { "?.lua", "?/init.lua" }
    for i = 1, #import_paths do
        local path = import_paths[i]
        paths[#paths + 1] = path .. "/?.lua"
        paths[#paths + 1] = path .. "/?.init.lua"
    end

    return paths
end

-- path list for loading definition files.
-- Note:
-- - All runtime paths rather than pwd, should be in this list.
-- - workspace path shouldn't be in lib path, some LSP features such as renaming
--   are turned of on file under lib path.
local function get_library_paths(is_in_nvim_runtime_path)
    local paths = {}

    -- Loading runtime path
    local import_paths = get_import_paths(is_in_nvim_runtime_path)
    vim.list_extend(paths, import_paths)

    -- User defined EmmyLua
    local emmylua_path = fs.path_join(user.env.APP_PATH(), "EmmyLua", "lua-lib-annotation")
    paths[#paths + 1] = emmylua_path

    -- Remove paths under current workspace
    local workspace_path = workspace.get_workspace_path()
    paths = functional.filter(paths, function(_, path)
        return not fs.is_subdir_of(path, workspace_path)
    end)

    paths = fs.path_list_dedup(paths)

    return paths
end

---@return string[] runtime_paths
---@return string[] library_paths
function M.get_path_setting(is_in_nvim_runtime_path)
    local runtime_paths = get_runtime_paths(is_in_nvim_runtime_path)
    local library_paths = get_library_paths(is_in_nvim_runtime_path)
    return runtime_paths, library_paths
end

return M
