local user = require "user"

user.plugin.null_ls = {
    __new_entry = true,
    sources = {},
}

return function()
    require("null-ls").setup(user.plugin.null_ls())
end
