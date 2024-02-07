local user = require "user"
local import = require "user.utils".import

local windows = import "user.config.platforms.windows"
if not windows then
    return
end
