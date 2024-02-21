local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local env_config_home = vim.env.CONFIG_HOME
if not env_config_home then
    log_util.error "initialize failed, can't find environment variable 'CONFIG_HOME'"
    return {}
end

local DEV_PATH = vim.env.DEV_PATH or fs_util.path_join(vim.env.HOME, "Developer")

return {
    ENV_CONFIG_INIT_OK = true,

    NVIM_HOME = fs_util.path_join(env_config_home, "nvim"),
    USER_RUNTIME_PATH = fs_util.path_join(env_config_home, "nvim", "lua"),

    PROXY_URL = vim.env.PROXY_URL or "",
    PLATFORM_MARK = vim.env.PLATFORM_MARK or "",
    HOME = vim.env.HOME or "",
    APP_PATH = vim.env.APP_PATH or "",
    DEV_PATH = DEV_PATH,
    LANG_PATH = vim.env.LANG_PATH or "",
    PLUGIN_DEV_PATH = fs_util.path_join(DEV_PATH, "nvim-plugins"),

    CC = vim.env.CC or "cc",
    FIREFOX_PATH = "",
    PYTHON_PATH = vim.env.PYTHON_PATH or "python",
    TS_LIB_PATH = vim.env.TS_LIB_PATH or "",
    YARN_GLOBAL_DIR = vim.env.YARN_GLOBAL_DIR or fs_util.path_join(vim.env.HOME or "~", ".config", "yarn", "global"),

    APPDATA = vim.env.APPDATA or "",

    LOAD_NVIM_RUNTIME = vim.env.LOAD_NVIM_RUNTIME or false,
}
