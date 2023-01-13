local user = require "user"
local import = require "user.utils".import
local fs = require "user.utils.fs"

local mark = vim.env.PLATFORM_MARK
local platform_config = mark
    and fs.path_join(
        user.env.CONFIG_HOME(), "user", "platforms", mark .. ".lua"
    )
    or ""

return vim.fn.filereadable(platform_config) == 1
    and import(platform_config)
    or nil
