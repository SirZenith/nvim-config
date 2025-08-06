local user = require "user"
local util = require "user.util"
local module_loaders = require "user.util.module_loaders"

local runtime_path = user.env.USER_RUNTIME_PATH()
util.compile_config(
    vim.fs.joinpath(runtime_path, "user"),
    vim.fs.joinpath(runtime_path, module_loaders.BYTE_CODE_DIR_NAME),
    {
        quiet = true,
    }
)
