local fs = require "user.utils.fs"

local env_config_home = vim.env.CONFIG_HOME
if not env_config_home then
    local err = "failed to initialize, Can't find environment variable 'CONFIG_HOME'"
    vim.notify(err, vim.log.levels.ERROR)

    return {}, err
end

return {
    env = {
        NVIM_HOME = fs.path_join(env_config_home, "nvim"),
        USER_RUNTIME_PATH = fs.path_join(env_config_home, "nvim", "lua"),

        PROXY_URL = vim.env.PROXY_URL or "",
        PLATFORM_MARK = vim.env.PLATFORM_MARK or "",
        HOME = vim.env.HOME or "",
        APP_PATH = vim.env.APP_PATH or "",
        DEV_PATH = vim.env.DEV_PATH or fs.path_join(vim.env.HOME, "Developer"),
        PLUGIN_DEV_PATH = fs.path_join(vim.env.DEV_PATH, "nvim-plugins"),

        CC = vim.env.CC or "cc",
        PYTHON_PATH = vim.env.PYTHON_PATH or "python",
        TS_LIB_PATH = vim.env.TS_LIB_PATH or "",
        APPDATA = vim.env.APPDATA or "",

        LOAD_NVIM_RUNTIME = vim.env.LOAD_NVIM_RUNTIME or false,
    },
    general = {},
    keybinding = {},
    option = {
        o = {},
        go = {},
        g = {},
    },
    platform = {},
    plugin = {},
    theme = {
        colorscheme = "",
        lualine_theme = "",
    },
}
