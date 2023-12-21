local fs = require "user.utils.fs"

local env_config_home = vim.env.CONFIG_HOME
if not env_config_home then
    local err = "failed to initialize, Can't find environment variable 'CONFIG_HOME'"
    vim.notify(err, vim.log.levels.ERROR)

    return  {}, err
end

return {
    env = {
        NVIM_HOME = fs.path_join(env_config_home, "nvim"),
        CONFIG_HOME = fs.path_join(env_config_home, "nvim", "lua"),
        PROXY_URL = vim.env.PROXY_URL,
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
