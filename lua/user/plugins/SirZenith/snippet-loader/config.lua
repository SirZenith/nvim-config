local user = require "user"
local fs = require "user.utils.fs"

user.plugin.snippet_loader = {
    __new_entry = true,
    root_path = fs.path_join(user.env.USER_RUNTIME_PATH(), "user", "snippets"),
}

return function()
    require "snippet-loader".setup(user.plugin.snippet_loader())
end
