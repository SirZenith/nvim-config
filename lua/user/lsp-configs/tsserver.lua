local user = require "user"
local fs_util = require "user.util.fs"

local M = {}

local formatting_pref = {
    baseIndentSize = 0,
    indentSize = 4,
    tabSize = 4,
    convertTabsToSpaces = true,
    indentStyle = "Smart",
    newLineCharacter = '\n',
    semicolons = "insert",
    trimTrailingWhitespace = true,

    -- Whitespace and functions
    insertSpaceAfterConstructor = false,
    insertSpaceAfterFunctionKeywordForAnonymousFunctions = false,
    insertSpaceBeforeFunctionParenthesis = false,

    -- Whitespace and control character
    insertSpaceAfterKeywordsInControlFlowStatements = true,
    insertSpaceAfterSemicolonInForStatements = true,
    insertSpaceAfterCommaDelimiter = true,
    insertSpaceBeforeAndAfterBinaryOperators = true,

    -- Whitespace and type annotation
    insertSpaceAfterTypeAssertion = true,
    insertSpaceBeforeTypeAnnotation = false,

    -- Whitespace and brackets
    insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false,
    insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = true,
    insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
    insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
    insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
    insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,

    -- Line break before brace
    placeOpenBraceOnNewLineForControlBlocks = false,
    placeOpenBraceOnNewLineForFunctions = false,
}

local function get_ts_lib_path()
    local tslib_path = user.env.TS_LIB_PATH()

    if not tslib_path or #tslib_path == 0 then
        local npm_prefix = vim.fn.has("WIN32") == 1 and user.env.APPDATA() or "/usr/local"
        tslib_path = fs_util.path_join(npm_prefix, "npm", "node_modules", "typescript", "lib")
    end

    return tslib_path
end

M.init_options = {
    plugins = {
        { name = "typescript-eslint-language-service" },
    },
    preferences = {
        quotePreference = "single",

        importModuleSpecifierPreference = "non-relative",

        includeInlayParameterNameHints = "none",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = true,
    },
}

M.settings = {
    typescript = {
        format = formatting_pref,
    },
    javascript = {
        format = formatting_pref,
    }
}

function M.before_init(_param, config)
    config.cmd = {
        "typescript-language-server",
        "--stdio",
        "--tsserver-path",
        get_ts_lib_path(),
    }
end

return M
