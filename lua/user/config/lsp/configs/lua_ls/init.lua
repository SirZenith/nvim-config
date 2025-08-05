local user = require "user"
local lspconfig_util = require "lspconfig.util"

local fs_util = require "user.util.fs"
local lsp_util = require "user.config.lsp.util"
local workspace = require "user.config.workspace"

local paths = require "user.config.lsp.configs.lua_ls.paths"

---@type vim.lsp.Config
local M = {}

M.settings = {
    Lua = {
        completion = {
            displayContext = 2,
            requireSeparator = ".",
        },
        diagnostics = {
            globals = {},
        },
        doc = {
            privateName = {
                "__[%w_]+"
            },
            protectedName = {
                "_%w[%w_]*",
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
        misc = {
            -- parameters = { "--loglevel", "info" },
        },
        runtime = {
            path = {},
            pathStrict = true,
            special = {},
            version = "LuaJIT",
        },
        workspace = {
            checkThirdParty = false,
            ignoreDir = {
                ".nvim"
            },
            -- Annotation files path
            library = {},
            userThirdParty = {
                fs_util.path_join(user.env.LANG_PATH(), "Lua", "luals-addons"),
            },
        }
    }
}

function M.before_init(_param, config)
    local root_dir = config.root_dir
    if not root_dir then return end

    local settings = config.settings
    if not settings then
        settings = {}
        config.settings = settings
    end

    local is_in_runtime_path = paths.check_in_nvim_runtime_path(root_dir)

    local runtime_version = "Lua 5.4"
    if is_in_runtime_path then
        runtime_version = "LuaJIT"
    elseif paths.check_in_library_directory(root_dir) then
        runtime_version = "Lua 5.1"
    end

    lsp_util.append_config_entry(settings, "Lua.diagnostics.globals", is_in_runtime_path and "vim" or nil)
    lsp_util.upsert_config_entry(settings, "Lua.runtime.version", runtime_version)
    lsp_util.upsert_config_entry(settings, "Lua.runtime.special.import", is_in_runtime_path and "require" or nil)

    local runtime_paths, library_paths = paths.get_path_setting(root_dir)
    lsp_util.upsert_config_entry(settings, "Lua.runtime.path", runtime_paths)
    lsp_util.upsert_config_entry(settings, "Lua.workspace.library", library_paths)
end

local function get_root_dir(fname)
    local dir = vim.fs.dirname(fname)

    if vim.fs.basename(dir) == workspace.WORKSPACE_CONFIG_DIR_NAME then
        return dir
    end

    -- neovim runtime directory
    do
        local root = vim.fs.root(fname, { "lua" })
        if root then
            return root .. '/lua'
        end
    end

    -- root files
    do
        local root = vim.fs.root(fname, {
            "preprocess.lua", -- delite library support
            {
                ".luarc.json",
                ".luarc.jsonc",
                ".luacheckrc",

                ".stylua.toml",
                "stylua.toml",

                "selene.toml",
                "selene.yml",
            },
            ".git",
        })

        if root and root ~= vim.env.HOME then
            return root
        end
    end

    return nil
end

function M.root_dir(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root_dir = get_root_dir(fname)
    if root_dir then
        on_dir(root_dir)
    end
end

return M
