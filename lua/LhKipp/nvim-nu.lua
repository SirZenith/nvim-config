local user = require "user"

user.nvim_nu = {
    complete_cmd_names = true,
    cmd_list = nil,
}

return function()
    require('nu').setup(user.nvim_nu())
end
