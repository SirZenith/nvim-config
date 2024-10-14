local user = require "user"
local import = require "user.util".import

local linux = import "user.config.platform.linux"
if not linux then
    return
end
