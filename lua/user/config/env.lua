local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local env_home = vim.env.HOME or vim.env.USERPROFILE
local nvim_home = fs_util.path_join(env_home, ".dotfiles", "Configs", "nvim", ".config", "nvim")
local dev_path = vim.env.DEV_PATH or fs_util.path_join(env_home, "Developer")

return {
    ENV_CONFIG_INIT_OK = true,

    NVIM_HOME = nvim_home,
    USER_RUNTIME_PATH = fs_util.path_join(nvim_home, "lua"),

    PROXY_URL = vim.env.PROXY_URL or "",
    PLATFORM_MARK = vim.env.PLATFORM_MARK or "",
    HOME = env_home or "",
    APP_PATH = vim.env.APP_PATH or "",
    DEV_PATH = dev_path,
    LANG_PATH = vim.env.LANG_PATH or "",
    PLUGIN_DEV_PATH = fs_util.path_join(dev_path, "nvim-plugins"),

    CC = vim.env.CC or "cc",
    FIREFOX_PATH = "",
    PYTHON_PATH = vim.env.PYTHON_PATH or "python",
    TS_LIB_PATH = vim.env.TS_LIB_PATH or "",
    BUN_GLOBAL_DIR = vim.env.BUN_GLOBAL_DIR or fs_util.path_join(env_home or "~", ".bun", "install", "global"),
    NPM_GLOBAL_DIR = vim.env.NPM_GLOBAL_DIR or "",
    YARN_GLOBAL_DIR = vim.env.YARN_GLOBAL_DIR or fs_util.path_join(env_home or "~", ".config", "yarn", "global"),

    APPDATA = vim.env.APPDATA or "",

    LOAD_NVIM_RUNTIME = vim.env.LOAD_NVIM_RUNTIME or false,
}
