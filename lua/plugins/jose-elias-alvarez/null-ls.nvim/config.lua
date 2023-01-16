local user = require "user"

user.null_ls = {
    sources = {}
}

return function()
    require("null-ls").setup(user.null_ls())
end
