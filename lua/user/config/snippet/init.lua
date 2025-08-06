local user = require "user"

user.snippet = {
    __newentry = true,
    root_path = vim.fs.joinpath(user.env.USER_RUNTIME_PATH(), "user", "config", "snippet", "configs"),
}
