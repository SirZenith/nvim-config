local user = require "user"
local highlight = require "user.config.theme.highlight"

user.plugin.indent_blankline_nvim = {
    __newentry = true,
    indent = {
        char = "|",
    },
    scope = {
        char = "│",
        highlight = highlight.rainbow_hl_groups,
        show_end = false,
    },
}

return user.plugin.indent_blankline_nvim:with_wrap(function(value)
    local ibl = require "ibl"
    local hooks = require "ibl.hooks"

    ibl.setup(value)

    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
end)
