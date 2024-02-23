local user = require "user"

user.plugin.cmd_snippet = {
    __default = true,
    -- Command snippet triggering prefix
    ---@type string
    cmd_head_char = "::",
    -- Command snippet finishing string
    ---@type string
    cmd_tail_char = ";",
}

return user.plugin.cmd_snippet:with_wrap(function(value)
    require "cmd-snippet".setup(value)
end)
