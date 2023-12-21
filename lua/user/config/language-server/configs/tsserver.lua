local user =  require "user"
local fs = require "user.utils.fs"

local M = {}

local tslib_path = user.env.TS_LIB_PATH()
if not tslib_path or #tslib_path == 0 then
    local npm_prefix = vim.fn.has("WIN32") == 1 and user.env.APPDATA() or "/usr/local"
    tslib_path = fs.path_join(npm_prefix, "npm", "node_modules", "typescript", "lib")
end

M.cmd = {
    "typescript-language-server",
    "--stdio",
    "--tsserver-path",
    tslib_path,
}

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

---@param client lsp.Client
function M.on_attach(client)
    client.rpc.notify("workspace/didChangeConfiguration", {
        settings = {
            typescript = {
                format = formatting_pref,
            },
        }
    })
end

return M
