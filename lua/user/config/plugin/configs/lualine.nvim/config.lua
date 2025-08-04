local user = require "user"

local comp_maco = require "user/config/plugin/configs/lualine.nvim/component_macro"

user.plugin.lualine = {
    __newentry = true,
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = "│",
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {
                "startup"
            },
            winbar = {},
        },
        ignore_focus = {
            "dapui_breakpoints",
            "dapui_console",
            "dapui_repl",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",

            "NvimTree",

            "MongoshNvimDBSideBar"
        },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 100,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = {
            { "mode", separator = { left = "" }, right_padding = 2 },
            comp_maco,
        },
        lualine_b = { "branch", "diff", "filename" },
        lualine_c = {
            {
                "lsp_status",
                icon = "󰷊",
                symbols = {
                    spinner = {
                        "%#LspStatusSpinner1#󱑊 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱐿 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑀 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑁 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑂 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑃 %#lualine_c_normal#",

                        "%#LspStatusSpinner2#󱑄 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑅 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑆 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑇 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑈 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑉 %#lualine_c_normal#",

                        "%#LspStatusSpinner3#󱑊 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱐿 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑀 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑁 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑂 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑃 %#lualine_c_normal#",

                        "%#LspStatusSpinner1#󱑄 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑅 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑆 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑇 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑈 %#lualine_c_normal#",
                        "%#LspStatusSpinner1#󱑉 %#lualine_c_normal#",

                        "%#LspStatusSpinner2#󱑊 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱐿 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑀 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑁 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑂 %#lualine_c_normal#",
                        "%#LspStatusSpinner2#󱑃 %#lualine_c_normal#",

                        "%#LspStatusSpinner3#󱑄 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑅 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑆 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑇 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑈 %#lualine_c_normal#",
                        "%#LspStatusSpinner3#󱑉 %#lualine_c_normal#",
                    },
                    done = "✨",
                    separator = "  ",
                },
                -- List of LSP names to ignore (e.g., `null-ls`):
                ignore_lsp = {},
            },
            {
                "diagnostics",

                -- Table of diagnostic sources, available sources are:
                --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                -- or a function that returns a table as such:
                --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                sources = { "nvim_lsp" },

                -- Displays diagnostics for the defined severity types
                sections = { "error", "warn", "info", "hint" },

                diagnostics_color = {
                    -- Same values as the general color option can be used here.
                    error = "LspStatusIndicatorErrors",
                    warn  = "LspStatusIndicatorWarnings",
                    info  = "LspStatusIndicatorInfo",
                    hint  = "LspStatusIndicatorHint",
                },
                symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
                colored = true,           -- Displays diagnostics status in color if set to true.
                update_in_insert = false, -- Update diagnostics in insert mode.
                always_visible = false,   -- Show diagnostics even if there are none.
            },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = {
            { "location", separator = { right = "" }, left_padding = 2 },
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

return function()
    local value = user.plugin.lualine()
    local lualine = require "lualine"

    local theme = user.theme.lualine_theme()
    value.options.theme = theme

    lualine.setup(value)
end
