local js_formatter = require "user/plugins/conform.nvim/util/js_formatter"

---@type user.plugin.FormatterFileTypeMap
local map = {
    ["_"] = { "trim_whitespace" },
    javascript = js_formatter.get_formatters,
    typescript = js_formatter.get_formatters,
}

return map
