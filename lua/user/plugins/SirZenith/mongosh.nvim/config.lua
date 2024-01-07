local user = require "user"

user.plugin.mongosh_nvim = {
    __new_entry = true,
}

return function()
    require "mongosh-nvim".setup(user.plugin.mongosh_nvim())
end
