local lspconfig_util = require "lspconfig.util"

local user = require "user"
local fs = require "user.utils.fs"
local lsp_util = require "user.utils.lsp"
local workspace = require "user.workspace"

local paths = require "user.lsp-configs.lua_ls.paths"

local M = {}

---@return boolean
local function check_in_nvim_runtime_path()
    local workspace_path = workspace.get_workspace_path()

    local is_nvim_runtime_path = fs.is_subdir_of(workspace_path, user.env.NVIM_HOME())
        or vim.fs.basename(workspace_path) == workspace.WORKSPACE_CONFIG_DIR_NAME
        or fs.is_subdir_of(workspace_path, vim.fn.stdpath("data"))
        or fs.is_subdir_of(workspace_path, user.env.PLUGIN_DEV_PATH())
        or user.env.LOAD_NVIM_RUNTIME()

    return is_nvim_runtime_path
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
            parameters = { "--loglevel", "info" },
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
        }
    }
}

function M.on_new_config(config)
    local settings = config.settings
    if not settings then
        settings = {}
        config.settings = settings
    end

    local is_in_runtime_path = check_in_nvim_runtime_path()

    lsp_util.upsert_config_entry(settings, "Lua.runtime.version", is_in_runtime_path and "LuaJIT" or "Lua 5.4")
    lsp_util.upsert_config_entry(settings, "Lua.runtime.special.import", is_in_runtime_path and "require" or nil)

    local runtime_paths, library_paths = paths.get_path_setting(is_in_runtime_path)
    lsp_util.upsert_config_entry(settings, "Lua.runtime.path", runtime_paths)
    lsp_util.upsert_config_entry(settings, "Lua.workspace.library", library_paths)
end

function M.root_dir(fname)
    local root_files = {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
    }

    local root = lspconfig_util.root_pattern(unpack(root_files))(fname)
    if root and root ~= vim.env.HOME then
        return root
    end

    root = lspconfig_util.root_pattern 'lua/' (fname)
    if root then
        return root .. '/lua'
    end

    return lspconfig_util.find_git_ancestor(fname)
end

return M
