local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

user.plugin.nvim_autopairs = {
    __new_entry = true,
    -- set to false means even always do pairing
    -- even there is unclosed pair following cursor position.
    enable_check_bracket_line = false,
}

local function finalize(module)
    module.setup(user.plugin.nvim_autopairs())
end

return wrap_with_module("nvim-autopairs", finalize)
