local user = require "user"

local highlight = require "user.config.theme.highlight"

user.theme = {
    __newentry = true,
    highlight = highlight.highlight,
}

-- ----------------------------------------------------------------------------

return function()
    vim.cmd "filetype plugin indent on"
end
