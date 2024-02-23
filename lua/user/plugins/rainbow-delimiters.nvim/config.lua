local user = require "user"
local highlight = require "user.config.general.highlight"

user.plugin.rainbow_delimiters_nvim = {
    __default = true,
    highlight = highlight.rainbow_hl_groups,
}

return user.plugin.rainbow_delimiters_nvim:with_wrap(function(value)
    require "rainbow-delimiters.setup".setup(value)
end)
