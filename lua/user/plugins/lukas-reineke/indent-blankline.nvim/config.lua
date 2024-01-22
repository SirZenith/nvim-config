local user = require "user"
local highlight = require "user.config.general.highlight"

user.plugin.indent_blankline_nvim = {
    __new_entry = true,
    scope = {
        highlight = highlight.rainbow_hl_groups,
    },
}

return function()
    local ibl = require "ibl"
    ibl.setup(user.plugin.indent_blankline_nvim())
end
