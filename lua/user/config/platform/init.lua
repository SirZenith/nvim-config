local user = require "user"
local util = require "user.util"
local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local import = util.import

---@class user.platform.ImSelectInfo
---@field check? string
---@field on? string
---@field off? string
---@field isoff? fun(im: string): boolean
--
---@field ignore_comment_filetype string[]
---@field should_reactivate fun(): boolean

local mark = user.env.PLATFORM_MARK()
local platform_config = mark
    and fs_util.path_join(
        user.env.USER_RUNTIME_PATH(), "user", "config", "platform", mark
    )
    or ""

user.platform = {
    __newentry = true,
}

-- ----------------------------------------------------------------------------

local module = user:with_source(
    user.__source_type.Platform,
    import,
    platform_config,
    ""
)

if module then
    log_util.trace("platform config:", platform_config)
end

return module
