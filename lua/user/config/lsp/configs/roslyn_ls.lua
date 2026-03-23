---@type vim.lsp.Config
local M = {
    offset_encoding = 'utf-16',
    settings = {
        ["csharp|background_analysis"] = {
            -- Option to turn configure background analysis scope for the current
            -- user. Note: setting this to "fullSolution" may result in significant
            -- performance degradation, see: https://github.com/dotnet/vscode-csharp/issues/8145#issuecomment-2784568100
            ---@type "openFiles" | "fullSolution" | "none"
            dotnet_analyzer_diagnostics_scope = "openFiles",

            -- Option to configure compiler diagnostics scope for the current user.
            -- Note: setting this to "fullSolution" may result in significant
            -- performance degradation, see: https://github.com/dotnet/vscode-csharp/issues/8145#issuecomment-2784568100
            ---@type "openFiles" | "fullSolution" | "none"
            dotnet_compiler_diagnostics_scope = "openFiles",
        },
        ["csharp|inlay_hints"] = {
            ---@type boolean
            dotnet_enable_inlay_hints_for_parameters = false,
            ---@type boolean
            dotnet_enable_inlay_hints_for_literal_parameters = false,
            ---@type boolean
            dotnet_enable_inlay_hints_for_indexer_parameters = false,
            ---@type boolean
            dotnet_enable_inlay_hints_for_object_creation_parameters = false,
            ---@type boolean
            dotnet_enable_inlay_hints_for_other_parameters = false,
            ---@type boolean
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
            ---@type boolean
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
            ---@type boolean
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
            ---@type boolean
            csharp_enable_inlay_hints_for_types = false,
            ---@type boolean
            csharp_enable_inlay_hints_for_implicit_variable_types = false,
            ---@type boolean
            csharp_enable_inlay_hints_for_lambda_parameter_types = false,
            ---@type boolean
            csharp_enable_inlay_hints_for_implicit_object_creation = false,
            ---@type boolean
            csharp_enable_inlay_hints_for_collection_expressions = false,
        },
        ["csharp|code_lens"] = {
            ---@type boolean
            dotnet_enable_references_code_lens = true,
            ---@type boolean
            dotnet_enable_tests_code_lens = true,
        },
        ["csharp|completion"] = {
            ---@type boolean
            dotnet_show_name_completion_suggestions = true,
            ---@type boolean
            dotnet_provide_regex_completions = true,

            -- Whether to show completion items from namespaces that are not imported.
            -- For example, if this is set to true, and you don't have the namespace
            -- `System.Net.Sockets` imported, then when you type "Sock" you will not
            -- get completion for `Socket` or other items in that namespace.
            ---@type boolean
            dotnet_show_completion_items_from_unimported_namespaces = false,

            ---@type boolean
            dotnet_trigger_completion_in_argument_lists = true,
        },
        ["csharp|highlighting"] = {
            ---@type boolean
            dotnet_highlight_related_json_components = true,
            ---@type boolean
            dotnet_highlight_related_regex_components = true,
        },
        ["csharp|navigation"] = {
            ---@type boolean
            dotnet_navigate_to_decompiled_sources = true,
            ---@type boolean
            dotnet_navigate_to_source_link_and_embedded_sources = true,
        },
        ["csharp|projects"] = {
            -- A folder to log binlogs to when running design-time builds.
            ---@type string?
            dotnet_binary_log_path = nil,
            -- Whether or not automatic nuget restore is enabled.
            ---@type boolean
            dotnet_enable_automatic_restore = true,
            -- Whether to use the new 'dotnet run app.cs' (file-based programs)
            -- experience.
            ---@type boolean
            dotnet_enable_file_based_programs = true,
            -- Whether to use the new 'dotnet run app.cs' (file-based programs)
            -- experience in files where the editor is unable to determine with
            -- certainty whether the file is a file-based program.
            ---@type boolean
            dotnet_enable_file_based_programs_when_ambiguous = true,
        },
        ["csharp|symbol_search"] = {
            ---@type boolean
            dotnet_search_reference_assemblies = true,
        },
    },
    -- Roslyn LS is quite resource intensive... We want to be 100% sure that it
    -- is closed and not orphaned (e.g., if nvim crashes).
    detached = false,
}

return M
