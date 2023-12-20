local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

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

local function finalize(module)
    module.setup(user.plugin.nvim_cursorline())
end

return wrap_with_module("nvim-cursorline", finalize)
