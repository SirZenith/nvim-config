local user = require "user"
local fs_util = require "user.util.fs"
local functional_util = require "user.util.functional"
local str_util = require "user.util.str"
local table_util = require "user.util.table"
local workspace = require "user.config.workspace"

local M = {}

local NVIM_RUNTIME_PATH_PATTERN = {
    "nvim/runtime",
}

local PLUGIN_TARGETS = {
    "cmd-snippet",
    "LuaSnip",
    "noice.nvim",
    "nvim-cmp",
    "nvim-lspconfig",
    "mongosh.nvim",
    "panelpal.nvim",
    "snippet-loader",
    "conform.nvim",
}

local ADDON_LIBRARIES = {
    "delite",
    "luafilesystem",
    "luasocket",
    "luasocket-luli",
}

---@param root_dir string
local function get_import_paths(root_dir)
    local is_in_nvim_runtime_path = M.check_in_nvim_runtime_path(root_dir)

    local paths = {}

    -- Add user runtime path when editing workspace config
    if vim.fs.basename(root_dir) == workspace.WORKSPACE_CONFIG_DIR_NAME then
        paths[#paths + 1] = user.env.USER_RUNTIME_PATH()
    end

    -- NeoVim Runtime Path
    if is_in_nvim_runtime_path then
        local list = vim.api.nvim_list_runtime_paths()

        for i = 1, #list do
            local path = vim.fs.normalize(list[i])

            for j = 1, #NVIM_RUNTIME_PATH_PATTERN do
                local patt = NVIM_RUNTIME_PATH_PATTERN[j]
                if path:match(patt) then
                    paths[#paths + 1] = path
                end
            end
        end
    end

    -- Plugin Main Path
    local plugin_names = {}
    for _, name in user.lsp.load_extra_plugins:ipairs() do
        plugin_names[#plugin_names + 1] = name
    end

    local workspace_path = workspace.get_workspace_path()
    if fs_util.is_subdir_of(workspace_path, user.env.NVIM_HOME()) then
        -- Used when editing user config.
        vim.list_extend(plugin_names, PLUGIN_TARGETS)
    end

    local plugin_root = fs_util.path_join(vim.fn.stdpath("data"), "lazy")
    for i = 1, #plugin_names do
        local name = plugin_names[i]
        paths[#paths + 1] = fs_util.path_join(plugin_root, name, "lua")
    end

    -- Lua import Path
    for _, path in ipairs(vim.split(package.path, ";")) do
        path = vim.fs.normalize(path)

        if str_util.ends_with(path, "?.lua") then
            path = path:sub(1, -6)
        elseif str_util.ends_with(path, "?/init.lua") then
            path = path:sub(1, -11)
        end

        if str_util.ends_with(path, "/") then
            path = path:sub(1, -2)
        end

        paths[#paths + 1] = path
    end

    for i = 1, #paths do
        paths[i] = vim.fs.normalize(paths[i])
    end

    paths = table_util.remove_duplicates(paths)

    return paths
end

-- path list for looking for required module.
-- pathes that are not in current workspace need also be presenting in
-- workspace.library setting to enable loading definition from those paths
---@param root_dir string
local function get_runtime_paths(root_dir)
    local is_in_nvim_runtime_path = M.check_in_nvim_runtime_path(root_dir)
    local import_paths = get_import_paths(root_dir)

    if is_in_nvim_runtime_path then
        local local_lua_dir = fs_util.path_join(root_dir, "lua")

        if vim.fn.isdirectory(local_lua_dir) == 1 then
            import_paths[#import_paths + 1] = local_lua_dir
        end
    end

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
--   All runtime paths rather than pwd, should be in this list.
--   workspace path shouldn't be in lib path, some LSP features such as renaming
--   are turned of on file under lib path.
---@param root_dir string
local function get_library_paths(root_dir)
    local paths = {}

    -- Loading runtime path
    local import_paths = get_import_paths(root_dir)
    vim.list_extend(paths, import_paths)

    -- Addon library definition
    local addon_dir = fs_util.path_join(user.env.LANG_PATH(), "Lua", "luals-addons")
    for _, name in ipairs(ADDON_LIBRARIES) do
        paths[#paths + 1] = fs_util.path_join(addon_dir, name, "library")
    end

    -- Remove paths under current workspace
    local workspace_path = workspace.get_workspace_path()
    paths = functional_util.filter(paths, function(_, path)
        return not fs_util.is_subdir_of(path, workspace_path)
    end)

    paths = fs_util.path_list_dedup(paths)

    return paths
end

---@param root_dir string
---@return boolean
function M.check_in_nvim_runtime_path(root_dir)
    local is_nvim_runtime_path = fs_util.is_subdir_of(root_dir, user.env.NVIM_HOME())
        or fs_util.is_subdir_of(root_dir, user.env.DOTFILES_HOME())
        or vim.fs.basename(root_dir) == workspace.WORKSPACE_CONFIG_DIR_NAME
        or fs_util.is_subdir_of(root_dir, vim.fn.stdpath("data"))
        or fs_util.is_subdir_of(root_dir, user.env.PLUGIN_DEV_PATH())
        or user.env.LOAD_NVIM_RUNTIME()

    return is_nvim_runtime_path
end

-- check_in_library_directory checks if root directory is a child of delite library
---@param root_dir string
---@return boolean
function M.check_in_library_directory(root_dir)
    local list = vim.fs.find({
        "library.json"
    }, {
        upward = true,
        path = root_dir,
    })

    return #list > 0
end

---@param root_dir string
---@return string[] runtime_paths
---@return string[] library_paths
function M.get_path_setting(root_dir)
    local runtime_paths = get_runtime_paths(root_dir)
    local library_paths = get_library_paths(root_dir)
    return runtime_paths, library_paths
end

return M
