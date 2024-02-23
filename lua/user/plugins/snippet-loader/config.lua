local user = require "user"
local fs_util = require "user.util.fs"

user.plugin.snippet_loader = {
    __default = true,
    root_path = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "snippets"),
}

return user.plugin.snippet_loader:with_wrap(function(value)
    require "snippet-loader".setup(value)
end)
