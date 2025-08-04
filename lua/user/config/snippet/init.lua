local user = require "user"
local fs_util = require "user.util.fs"

user.snippet = {
    __newentry = true,
    root_path = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "config", "snippet", "configs"),
}
