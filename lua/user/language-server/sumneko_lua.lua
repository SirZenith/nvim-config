local user = require "user"
local fs = require "user.utils.fs"
local functional = require "user.utils.functional"
local table_utils = require "user.utils.table"
local workspace = require "user.workspace"

local expand = vim.fn.expand

local M = {}

---@param path_list string[]
---@param path string
local function add_runtime_path(path_list, path)
    path_list[#path_list + 1] = vim.fs.normalize(fs.path_join(path, "?.lua"))
    path_list[#path_list + 1] = vim.fs.normalize(fs.path_join(path, "?", "init.lua"))
end

local workspace_path = workspace.get_workspace_path()
local is_nvim_config_path = vim.fs.dirname(workspace_path):starts_with(user.env.NVIM_HOME())
    or vim.fs.basename(workspace_path) == workspace.WORKSPACE_CONFIG_DIR_NAME
    or workspace_path:starts_with(vim.fn.stdpath("data"))

local runtime_version = is_nvim_config_path and "Lua 5.1" or "Lua 5.4"

-- pathes that are not in current workspace need also be
-- presenting in workspace.library setting.
local runtime_paths = (function()
    local tbl = {
        ".",
    }

    if vim.env.PLATFORM_MARK ~= "windows" then
        table_utils.extend_list(tbl, {
            expand "~/.luarocks/share/lua/5.3",
            expand "~/.luarocks/share/lua/5.4",
            "/usr/share/lua/5.3",
            "/usr/share/lua/5.4",
        })
    end

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

        table_utils.extend_list(tbl, list)
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

    runtime = table_utils.remove_duplicates(runtime, lua_path)

    return runtime
end)()

local lib_path = (function()
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

    -- 用户定义 EmmyLua
    local emmylua_path = fs.path_join(vim.env.APP_PATH or "", "EmmyLua", "lua-lib-annotation")
    tbl[#tbl + 1] = emmylua_path

    local lib = {}
    for i = 1, #tbl do
        lib[i] = vim.fs.normalize(tbl[i])
    end

    lib = table_utils.remove_duplicates(lib)

    return lib
end)()

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
            library = lib_path,
        }
    }
}

return M
