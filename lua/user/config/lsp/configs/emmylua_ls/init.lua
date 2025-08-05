local lsp_util = require "user.config.lsp.util"
local paths = require "user.config.lsp.configs.lua_ls.paths"

local lua_ls_cfg = require "user.config.lsp.configs.lua_ls"

---@alias user.lsp.emmylua_ls.Severity
---| "error"
---| "warning"
---| "infomation"
---| "hint"

---@alias user.lsp.emmylua_ls.LuaVersion
---| "Lua5.1"
---| "Lua5.2"
---| "Lua5.3"
---| "Lua5.4"
---| "LuaJIT"

---@enum user.lsp.emmylua_ls.DiagnosticEntry
local DiagnosticEntry = {
    SyntaxError                    = "syntax-error",
    DocSyntaxError                 = "doc-syntax-error",
    TypeNotFound                   = "type-not-found",
    MissingReturn                  = "missing-return",
    ParamTypeNotMatch              = "param-type-not-match",
    MissingParameter               = "missing-parameter",
    RedundantParameter             = "redundant-parameter",
    UnreachableCode                = "unreachable-code",
    Unused                         = "unused",
    UndefinedGlobal                = "undefined-global",
    Deprecated                     = "deprecated",
    AccessInvisible                = "access-invisible",
    DiscardReturns                 = "discard-returns",
    UndefinedField                 = "undefined-field",
    LocalConst_reassign            = "local-const-reassign",
    IterVariable_reassign          = "iter-variable-reassign",
    DuplicateType                  = "duplicate-type",
    RedefinedLocal                 = "redefined-local",
    RedefinedLabel                 = "redefined-label",
    CodeStyleCheck                 = "code-style-check",
    NeedCheckNil                   = "need-check-nil",
    AwaitInSync                    = "await-in-sync",
    AnnotationUsageError           = "annotation-usage-error",
    ReturnTypeMismatch             = "return-type-mismatch",
    MissingReturnValue             = "missing-return-value",
    REdundantReturnValue           = "redundant-return-value",
    UndefinedDocParam              = "undefined-doc-param",
    DuplicateDocField              = "duplicate-doc-field",
    MissingFields                  = "missing-fields",
    InjectField                    = "inject-field",
    CircleDocClass                 = "circle-doc-class",
    IncompleteSignatureDoc         = "incomplete-signature-doc",
    MissingGlobalDoc               = "missing-global-doc",
    AssignTypeMismatch             = "assign-type-mismatch",
    DuplicateRequire               = "duplicate-require",
    NonLiteralExpressionsIn_assert = "non-literal-expressions-in-assert",
    UnbalancedAssignments          = "unbalanced-assignments",
    UnnecessaryAssert              = "unnecessary-assert",
    UnnecessaryIf                  = "unnecessary-if",
    DuplicateSetField              = "duplicate-set-field",
    DuplicateIndex                 = "duplicate-index",
    GenericConstraintMismatch      = "generic-constraint-mismatch",
}

---@type vim.lsp.Config
local M = {
    root_dir = lua_ls_cfg.root_dir,
}

M.settings = {
    codeAction = {
        insertSpace = false,
    },
    codeLens = {
        enable = true,
    },
    completion = {
        enable = true,
        autoRequire = true,
        autoRequireFunction = "require",
        autoRequireNamingConvention = "keep",
        autoRequireSeparator = ".",
        callSnippet = false,
        postfix = "@",
    },
    diagnostics = {
        enable = true,
        diagnosticInterval = 500,

        ---@type string[] # diagnostic entry to disable
        disable = {},
        ---@type string[] # diagnostic entry to enable
        enables = {},
        ---@type table<string, user.lsp.emmylua_ls.Severity> # custom severity for specific diagnostic entry
        severity = vim.empty_dict(),

        globals = {},
        globalsRegex = {},
    },
    documentColor = {
        enable = true,
    },
    hint = {
        enable = true,
        indexHint = true,
        localHint = true,
        overrideHint = true,
        paramHint = true,
    },
    hover = {
        enable = true,
    },
    references = {
        enable = true,
        fuzzySearch = true,
        shortStringSearch = false,
    },
    resource = {
        paths = {},
    },
    runtime = {
        classDefaultCall = {
            forceNonColon = false,
            forceReturnSelf = false,
            functionName = "",
        },
        extensions = {
            ".lua",
        },
        frameworkVersions = {},
        requireLikeFunction = {},
        requirePattern = {
            "?.lua",
            "?/init.lua",
        },
        version = "LuaLatest",
    },
    semanticTokens = {
        enable = true,
    },
    signature = {
        detailSignatureHelper = true,
    },
    strict = {
        arrayIndex = true,
        docBaseConstMatchBaseType = true,
        metaOverrideFileDefine = true,
        requirePath = false,
        typeCall = false,
    },
    workspace = {
        enableReindex = false,
        encoding = "utf-8",
        ignoreDir = { ".nvim" },
        ignoreGlobs = {},
        library = {},
        moduleMap = {},
        preloadFileSize = 0,
        reindexDuration = 5000,
        workspaceRoots = {},
    },
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

    local runtime_version = "Lua5.4" ---@type user.lsp.emmylua_ls.LuaVersion
    if is_in_runtime_path then
        runtime_version = "LuaJIT"
    elseif paths.check_in_library_directory(root_dir) then
        runtime_version = "Lua5.1"
    end

    lsp_util.append_config_entry(settings, "diagnostics.globals", is_in_runtime_path and "vim" or nil)
    lsp_util.append_config_entry(settings, "runtime.requireLikeFunction", is_in_runtime_path and "import" or nil)
    lsp_util.upsert_config_entry(settings, "runtime.version", runtime_version)

    local runtime_paths, library_paths = paths.get_path_setting(root_dir)
    lsp_util.upsert_config_entry(settings, "workspace.library", library_paths)
end

return M
