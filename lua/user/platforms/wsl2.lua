local user = require "user"
local import = require "user.utils".import

local wsl = import "user.platforms.wsl"
if not wsl then
    return
end

