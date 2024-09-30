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
}

local inlay_hints = {
    parameterNames = {
        enabled = "literals",
        suppressWhenArgumentMatchesName = true,
    },
    parameterTypes = {
        enabled = true,
    },
    variableTypes = {
        enabled = true,
        suppressWhenTypeMatchesName = true,
    },
    propertyDeclarationTypes = {
        enabled = true,
    },
    functionLikeReturnTypes = {
        enabled = true,
    },
    enumMemberValues = {
        enabled = true,
    }
}

M.settings = {
    javascript = {
        inlayHints = inlay_hints,
        preferences = preference,
    },
    typescript = {
        inlayHints = inlay_hints,
        preferences = preference,
        tsserver = {
            -- path to package installation directory, e.g. `./node_modules` or
            -- directory printed by `yarn global dir`.
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
                {
                    -- Requires
                    -- typescript
                    -- @typescript-eslint/parser >= 5.0.0
                    -- eslint >= 8.0.0,
                    --    but < 9.0.0, starting from 9.0.0, eslint no longer
                    --    supports .eslintrc file
                    name = "typescript-eslint-language-service"
                },
            }
        },
        typescript = {
            format = formatting_pref,
        },
    },
}

return M
