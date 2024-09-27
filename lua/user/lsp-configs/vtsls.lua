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

local preference = {
    quotePreference = "single",

    importModuleSpecifier = "non-relative",

    includeInlayParameterNameHints = "none",
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints = false,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = false,
    includeInlayFunctionLikeReturnTypeHints = false,
    includeInlayEnumMemberValueHints = true,
}

M.settings = {
    javascript = {
        preferences = preference,
    },
    typescript = {
        preferences = preference,
        tsserver = {
            pluginPaths = {
                user.env.BUN_GLOBAL_DIR(),
            },
            useSeparateSyntaxServer = true,
            useSyntaxServer = true,
        },
    },
    vtsls = {
        autoUseWorkspaceTsdk = true,
        javascript = {
            format = formatting_pref,
        },
        tsserver = {
            globalPlugins = {
                { name = "typescript-eslint-language-service" },
            }
        },
        typescript = {
            format = formatting_pref,
        },
    },
}

return M
