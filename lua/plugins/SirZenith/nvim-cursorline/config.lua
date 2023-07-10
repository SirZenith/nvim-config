local user = require "user"

user.plugin.nvim_cursorline = {
    __new_entry = true,
    disable_in_filetype = { "floaterm" },
    disable_in_buftype = { "terminal" },
    cursorline = {
        enable = true,
        timeout = 500,
        no_line_number_highlight = false,
    },
    cursorword = {
        enable = true,
        timeout = 500,
        min_length = 3,
        hl = {
            fg = nil,
            bg = "#3e4b5c",
            underline = false,
        },
    }
}

return function()
    require('nvim-cursorline').setup(user.plugin.nvim_cursorline())
end
