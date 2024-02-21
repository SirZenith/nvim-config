local user = require "user"
local import = require "user.util".import

local windows = import "user.config.platforms.windows"
if not windows then
    return
end
