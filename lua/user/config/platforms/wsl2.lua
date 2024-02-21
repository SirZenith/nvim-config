local user = require "user"
local import = require "user.util".import

local wsl = import "user.config.platforms.wsl"
if not wsl then
    return
end
