local user = require "user"
local highlight = require "user.config.general.highlight"

user.plugin.rainbow_delimiters_nvim = {
    __new_entry = true,
    highlight = highlight.rainbow_hl_groups,
}

return function()
    require "rainbow-delimiters.setup".setup(user.plugin.rainbow_delimiters_nvim())
end
