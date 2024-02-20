local user = require "user"
local highlight = require "user.config.general.highlight"

user.plugin.indent_blankline_nvim = {
    __new_entry = true,
    indent = {
        char = "|",
    },
    scope = {
        char = "│",
        highlight = highlight.rainbow_hl_groups,
        show_end = false,
    },
}

return function()
    local ibl = require "ibl"
    local hooks = require "ibl.hooks"

    ibl.setup(user.plugin.indent_blankline_nvim())

    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
end
