local user = require "user"

user.plugin.cmd_snippet = {
    __new_entry = true,
    -- Command snippet triggering prefix
    ---@type string
    cmd_head_char = "::",
    -- Command snippet finishing string
    ---@type string
    cmd_tail_char = ";",
}

return function()
    require "cmd-snippet".setup(user.plugin.cmd_snippet())
end
