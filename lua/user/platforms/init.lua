local user = require "user"
local import = require "user.utils".import
local fs = require "user.utils.fs"

local platform_config = fs.path_join(
    user.env.CONFIG_HOME(), "user", "platforms", vim.env.PLATFORM_MARK .. ".lua"
)

return vim.fn.filereadable(platform_config) == 1
    and import(platform_config)
    or nil