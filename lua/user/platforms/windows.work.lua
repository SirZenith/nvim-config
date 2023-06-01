local plugins = require "user.plugins"
local windows = require "user.platforms.windows"

plugins.load_plugins {
    "MunifTanjim/eslint.nvim",
}

return windows
