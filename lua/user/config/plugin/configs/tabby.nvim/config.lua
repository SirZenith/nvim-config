local user = require "user"

local format_line = require "user/config/plugin/configs/tabby.nvim/line_builder"

return function()
    require "tabby".setup {
        line = format_line,
    }
end
