local user = require "user"

local highlight = require "user.config.general.highlight"
local option = require "user.config.general.option"
local sign = require "user.config.general.sign"

user.general = {
    __default = true,
    option = option,
    sign = sign,
    theme = {
        highlight = highlight.highlight,
    },
}

-- ----------------------------------------------------------------------------

return function()
    vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

    vim.cmd "filetype plugin indent on"

    for name, cfg in user.general.sign:pairs() do
        vim.fn.sign_define(name, cfg)
    end
end
