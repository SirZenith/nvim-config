local user = require "user"
local import = require "user.util".import

local wsl = import "user.config.platform.wsl"
if not wsl then
    return
end
