local user = require "user"
local fs = require "user.utils.fs"
local functional = require "user.utils.functional"
local table_utils = require "user.utils.table"
local workspace = require "user.workspace"

local M = {}

---@param path_list string[]
---@param path string
local function add_runtime_path(path_list, path)
    path_list[#path_list + 1] = vim.fs.normalize(fs.path_join(path, "?.lua"))
    path_list[#path_list + 1] = vim.fs.normalize(fs.path_join(path, "?", "init.lua"))
end

local workspace_path = workspace.get_workspace_path()
local is_nvim_runtime_path = fs.is_subdir_of(workspace_path, user.env.NVIM_HOME())
    or vim.fs.basename(workspace_path) == workspace.WORKSPACE_CONFIG_DIR_NAME
    or fs.is_subdir_of(workspace_path, vim.fn.stdpath("data"))
    or fs.is_subdir_of(workspace_path, user.env.PLUGIN_DEV_PATH())
    or user.env.LOAD_NVIM_RUNTIME()

local runtime_version = is_nvim_runtime_path and "LuaJIT" or "Lua 5.4"

-- path list for looking for required module.
-- pathes that are not in current workspace need also be presenting in
-- workspace.library setting to enable loading definition from those paths
local runtime_paths
do
    local tbl = {
        ".",
    }

    -- Vim
    if is_nvim_runtime_path then
        tbl[#tbl + 1] = user.env.USER_RUNTIME_PATH()

        local patterns = {
            "nvim/runtime",
            "LuaSnip",
            "nvim%-lspconfig",
            "panelpal%.nvim",
            "nvim%-cmp",
            "noice%.nvim",
            "snippet%-loader",
            "mongosh%.nvim",
        }

        local list = vim.api.nvim_list_runtime_paths()
        list = functional.filter(list, function(_, path)
            path = vim.fs.normalize(path) ---@type string

            return functional.any(patterns, function(_, patt)
                return not workspace_path:match(patt) and path:match(patt) ~= nil
            end)
        end)

        local list_mapped = functional.map(list, function(_, path)
            return fs.path_join(path, "lua")
        end)

        table_utils.extend_list(tbl, list_mapped)

        if vim.fn.isdirectory("lua") then
            tbl[#tbl + 1] = fs.path_join(workspace_path, "lua")
        end
    end

    -- Lua Path
    local lua_path = {}
    for _, path in ipairs(vim.split(package.path, ";")) do
        lua_path[#lua_path + 1] = vim.fs.normalize(path)
    end

    local runtime = {}
    for i = 1, #tbl do
        add_runtime_path(runtime, tbl[i])
    end

    runtime_paths = table_utils.remove_duplicates(runtime, lua_path)
end

-- path list for loading definition files.
-- All runtime paths rather than pwd, should be in this list.
local lib_paths
do
    local tbl = { workspace_path }

    -- Loading runtime path
    for i = 1, #runtime_paths do
        local path = runtime_paths[i]

        local dir = vim.fs.dirname(path)
        while #dir > 0 and dir ~= "." and vim.fs.basename(dir) == "?" do
            dir = vim.fs.dirname(dir)
        end

        tbl[#tbl + 1] = dir
    end

    -- User defined EmmyLua
    local emmylua_path = fs.path_join(user.env.APP_PATH(), "EmmyLua", "lua-lib-annotation")
    tbl[#tbl + 1] = emmylua_path

    -- Dedup
    for i = 1, #tbl do
        tbl[i] = vim.fs.normalize(tbl[i])
    end

    table.sort(tbl, function(a, b)
        return a:len() < b:len()
    end)

    local lib = {}
    local dir_set = {}
    for _, path in ipairs(tbl) do
        local marked = false

        for dir in vim.fs.parents(path) do
            if dir_set[dir] then
                marked = true
                break
            end
        end

        if not marked then
            dir_set[path] = true
            lib[#lib + 1] = path
        end
    end

    lib_paths = lib
end

M.settings = {
    Lua = {
        completion = {
            displayContext = 2,
            requireSeparator = ".",
        },
        diagnostics = {
            globals = {
                "vim"
            },
        },
        format = {
            enable = true,
            -- Put format options here
            -- NOTE: the value should be STRING!!
            defaultConfig = {
                indent_style = "space",
                indent_size = "4",
            }
        },
        hover = {
            viewNumber = true,
            viewString = true,
        },
        runtime = {
            version = runtime_version,
            special = {
                import = is_nvim_runtime_path and "require" or nil
            },
            path = runtime_paths,
        },
        workspace = {
            checkThirdParty = false,
            ignoreDir = {
                ".nvim"
            },
            -- Annotation files path
            library = lib_paths,
        }
    }
}

M.root_dir = function()
    return vim.fn.getcwd()
end

return M
