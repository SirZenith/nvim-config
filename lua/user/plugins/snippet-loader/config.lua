local user = require "user"
local fs_util = require "user.util.fs"

user.plugin.snippet_loader = {
    __new_entry = true,
    root_path = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "snippets"),
}

return function()
    require "snippet-loader".setup(user.plugin.snippet_loader())
end
