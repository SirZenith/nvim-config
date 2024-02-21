local user = require "user"

user.plugin.nvim_autopairs = {
    __new_entry = true,
    -- set to false means even always do pairing
    -- even there is unclosed pair following cursor position.
    enable_check_bracket_line = false,
}

return user.plugin.nvim_autopairs:with_wrap(function(value)
    require "nvim-autopairs".setup(value)
end)
