local user = require "user"
local utils = require "user.utils"
local fs = require "user.utils.fs"

local loop = vim.loop
local import = utils.import

local mark = user.env.PLATFORM_MARK()
local platform_config = mark
    and fs.path_join(
        user.env.USER_RUNTIME_PATH(), "user", "config", "platforms", mark .. ".lua"
    )
    or ""

return "async", function(callback)
    callback = vim.schedule_wrap(callback)

    utils.do_async_steps {
        function(next_step)
            loop.fs_stat(platform_config, next_step)
        end,
        function(_, err, stat)
            print(platform_config)
            if err or stat then
                callback()
                return
            end

            local module = import(platform_config)
            callback(module)
        end,
    }
end
