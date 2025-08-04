local lsp_util = require "user.config.lsp.util"
local paths = require "user.config.lsp.configs.lua_ls.paths"

local M = {}

M.settings = {
    codeAction = {
        insertSpace = false
    },
    codeLens = {
        enable = true
    },
    completion = {
        autoRequire = true,
        autoRequireFunction = "require",
        autoRequireNamingConvention = "keep",
        autoRequireSeparator = ".",
        callSnippet = false,
        enable = true,
        postfix = "@"
    },
    diagnostics = {
        diagnosticInterval = 500,
        disable = {},
        enable = true,
        enables = {},
        globals = {},
        globalsRegex = {},
        severity = vim.empty_dict()
    },
    documentColor = {
        enable = true
    },
    hint = {
        enable = true,
        indexHint = true,
        localHint = true,
        overrideHint = true,
        paramHint = true
    },
    hover = {
        enable = true
    },
    references = {
        enable = true,
        fuzzySearch = true,
        shortStringSearch = false
    },
    resource = {
        paths = {}
    },
    runtime = {
        classDefaultCall = {
            forceNonColon = false,
            forceReturnSelf = false,
            functionName = ""
        },
        extensions = {},
        frameworkVersions = {},
        requireLikeFunction = {},
        requirePattern = {},
        version = "LuaLatest"
    },
    semanticTokens = {
        enable = true
    },
    signature = {
        detailSignatureHelper = true
    },
    strict = {
        arrayIndex = true,
        docBaseConstMatchBaseType = true,
        metaOverrideFileDefine = true,
        requirePath = false,
        typeCall = false
    },
    workspace = {
        enableReindex = false,
        encoding = "utf-8",
        ignoreDir = {
            ".nvim"
        },
        ignoreGlobs = {},
        library = {},
        moduleMap = {},
        preloadFileSize = 0,
        reindexDuration = 5000,
        workspaceRoots = {}
    }
}

function M.before_init(_param, config)
    local settings = config.settings
    if not settings then
        settings = {}
        config.settings = settings
    end

    local root_dir = config.root_dir
    local is_in_runtime_path = paths.check_in_nvim_runtime_path(root_dir)

    local runtime_version = "Lua 5.4"
    if is_in_runtime_path then
        runtime_version = "LuaJIT"
    elseif paths.check_in_library_directory(root_dir) then
        runtime_version = "Lua 5.1"
    end

    lsp_util.append_config_entry(settings, "diagnostics.globals", is_in_runtime_path and "vim" or nil)
    lsp_util.upsert_config_entry(settings, "runtime.version", runtime_version)
    -- lsp_util.upsert_config_entry(settings, "runtime.special.import", is_in_runtime_path and "require" or nil)

    local runtime_paths, library_paths = paths.get_path_setting(root_dir)
    -- lsp_util.upsert_config_entry(settings, "Lua.runtime.path", runtime_paths)
    lsp_util.upsert_config_entry(settings, "workspace.library", library_paths)
end

return M
