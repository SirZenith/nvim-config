local user = require "user"

user.plugin.nvim_autopairs = {
    __new_entry = true,
    -- set to false means even always do pairing
    -- even there is unclosed pair following cursor position.
    enable_check_bracket_line = false,
}

return function()
    require "nvim-autopairs".setup(user.plugin.nvim_autopairs())
end
