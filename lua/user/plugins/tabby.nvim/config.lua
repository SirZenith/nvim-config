local user = require "user"

local format_line = require "user/plugins/tabby.nvim/line_builder"

return function()
    require "tabby.tabline".set(format_line)
end
