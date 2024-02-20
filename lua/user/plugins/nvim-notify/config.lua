local user = require "user"

user.plugin.nvim_notify = {
    __new_entry = true,
    level = vim.log.levels.INFO,
    timeout = 2000,
    max_width = nil,
    max_height = nil,
    stages = "slide",
    render = "default",
    background_colour = "NotifyBackground",
    on_open = nil,
    on_close = nil,
    minimum_width = 50,
    fps = 30,
    top_down = true,
    time_formats = {
        notification_history = "%FT%T",
        notification = "%T",
    },
    icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
    },
}

return function()
    require "notify".setup(user.plugin.nvim_notify())
end