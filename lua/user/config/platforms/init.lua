local user = require "user"
local import = require "user.utils".import
local fs = require "user.utils.fs"

local mark = user.env.PLATFORM_MARK()
local platform_config = mark
    and fs.path_join(
        user.env.USER_RUNTIME_PATH(), "user", "config", "platforms", mark .. ".lua"
    )
    or ""

return vim.fn.filereadable(platform_config) == 1
    and import(platform_config)
    or nil