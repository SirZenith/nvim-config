local user = require "user"

user.plugin.nvim_unity_sync = {
    __newentry = true,
}

return user.plugin.nvim_unity_sync:with_wrap(function()
    require "unity.plugin".setup()
end)
