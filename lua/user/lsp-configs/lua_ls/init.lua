local lspconfig_util = require "lspconfig.util"

local lsp_util = require "user.utils.lsp"

local paths = require "user.lsp-configs.lua_ls.paths"

local M = {}

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

function M.on_new_config(config, root_dir)
    local settings = config.settings
    if not settings then
        settings = {}
        config.settings = settings
    end

    local is_in_runtime_path = paths.check_in_nvim_runtime_path(root_dir)

    lsp_util.upsert_config_entry(settings, "Lua.runtime.version", is_in_runtime_path and "LuaJIT" or "Lua 5.4")
    lsp_util.upsert_config_entry(settings, "Lua.runtime.special.import", is_in_runtime_path and "require" or nil)

    local runtime_paths, library_paths = paths.get_path_setting(root_dir)
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
