local user = require "user"

user.plugin.colorizer = {
    __newentry = true,
    "*",
    -- Hilight all filetype except:
    "!noice",
}

return user.plugin.colorizer:with_wrap(function(value)
    require "colorizer".setup(value)
end)
