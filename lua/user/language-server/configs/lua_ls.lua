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
local is_nvim_config_path = workspace_path:starts_with(user.env.NVIM_HOME())
    or vim.fs.basename(workspace_path) == workspace.WORKSPACE_CONFIG_DIR_NAME
    or workspace_path:starts_with(vim.fn.stdpath("data"))

local runtime_version = is_nvim_config_path and "LuaJIT" or "Lua 5.4"

-- pathes that are not in current workspace need also be
-- presenting in workspace.library setting.
local runtime_paths
do
    local tbl = {
        ".",
    }

    -- Vim
    if is_nvim_config_path then
        tbl[#tbl + 1] = user.env.CONFIG_HOME()

        local patterns = {
            "nvim/runtime",
            "LuaSnip",
            "nvim-lspconfig",
            "panelpal.nvim",
        }

        local list = vim.api.nvim_list_runtime_paths()
        list = functional.filter(list, function(_, path)
            path = vim.fs.normalize(path) ---@type string

            return functional.any(patterns, function(_, patt)
                return path:find(patt) ~= nil
            end)
        end)
        local list_mapped = {}
        for i = 1, #list do
            list_mapped[#list_mapped+1] = fs.path_join(list[i], "lua")
        end

        table_utils.extend_list(tbl, list_mapped)
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

local lib_paths
do
    local tbl = {}

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
    local emmylua_path = fs.path_join(vim.env.APP_PATH or "", "EmmyLua", "lua-lib-annotation")
    tbl[#tbl + 1] = emmylua_path

    local lib = {}
    for i = 1, #tbl do
        lib[i] = vim.fs.normalize(tbl[i])
    end

    lib_paths = table_utils.remove_duplicates(lib)
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
                import = is_nvim_config_path and "require" or nil
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

return M
