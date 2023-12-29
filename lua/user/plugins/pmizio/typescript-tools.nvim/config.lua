local user = require "user"
local table_utils = require "user.utils.table"

user.plugin.typescript_tools = {
    __new_entry = true,
    settings = {
        -- spawn additional tsserver instance to calculate diagnostics on it
        separate_diagnostic_server = true,
        -- "change"|"insert_leave" determine when the client asks the server about diagnostic
        publish_diagnostic_on = "insert_leave",
        -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
        -- "remove_unused_imports"|"organize_imports") -- or string "all"
        -- to include all supported code actions
        -- specify commands exposed as code_actions
        expose_as_code_action = { "all" },
        -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
        -- not exists then standard path resolution strategy is applied
        tsserver_path = nil,
        -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
        -- (see 💅 `styled-components` support section)
        tsserver_plugins = {
            "typescript-eslint-language-service",
        },
        -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
        -- memory limit in megabytes or "auto"(basically no limit)
        tsserver_max_memory = "auto",
        tsserver_format_options = {
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
        },
        tsserver_file_preferences = {
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
        -- locale of all tsserver messages, supported locales you can find here:
        -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
        tsserver_locale = "en",
        -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
        complete_function_calls = false,
        include_completions_with_insert_text = true,
        -- CodeLens
        -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
        -- possible values: ("off"|"all"|"implementations_only"|"references_only")
        code_lens = "off",
        -- by default code lenses are displayed on all referencable values and for some of you it can
        -- be too much this option reduce count of them by removing member references from lenses
        disable_member_code_lens = true,
        -- JSXCloseTag
        -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-auto-tag,
        -- that maybe have a conflict if enable this feature. )
        jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
        }
    },
}

return function()
    local loader = require "lsp-config-loader.loader"
    local typescript_tools = require "typescript-tools"

    local server = "tsserver"
    local tsserver_config = loader.load(
        server,
        user.lsp.server_config[server]()
    )

    table_utils.update_table(tsserver_config, user.plugin.typescript_tools())

    typescript_tools.setup(tsserver_config)
end
