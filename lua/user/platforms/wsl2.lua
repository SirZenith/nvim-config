local user = require "user"
local utils = require "user.utils"
local import = utils.import

local wsl = import "user.platforms.wsl"
if not wsl then
    return
end

