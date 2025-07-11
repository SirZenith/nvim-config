local user = require "user"

user.plugin.nvim_ts_autotag = {
    __newentry = true,
    opts = {
        -- Defaults
        enable_close = true,          -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = false -- Auto close on trailing </
    },
}

return user.plugin.nvim_ts_autotag:with_wrap(function(value)
    require "nvim-ts-autotag".setup(value)
end)
