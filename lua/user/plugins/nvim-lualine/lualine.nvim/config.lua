local user = require "user"

local comp_maco = require "user/plugins/nvim-lualine/lualine.nvim/component_macro"

user.plugin.lualine = {
    __new_entry = true,
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = "|",
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
        globalstatus = false,
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
        lualine_c = { 'require "lsp-status".status()' },
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
    local lualine = require "lualine"

    local theme = user.theme.lualine_theme()
    user.plugin.lualine.options.theme = theme

    lualine.setup(user.plugin.lualine())
end
