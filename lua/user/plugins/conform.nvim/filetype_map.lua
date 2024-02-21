local js_formatter_getter = require "user/plugins/conform.nvim/util/js_formatter_getter"

---@type user.plugin.FormatterFileTypeMap
local map = {
    ["_"] = { "trim_whitespace" },
    javascript = js_formatter_getter.get_formatters,
    typescript = js_formatter_getter.get_formatters,
}

return map
