local user = require "user"

user.plugin.colorizer = {
    __new_entry = true,
    "*",
    -- Hilight all filetype except:
    "!noice",
}

return function()
    require "colorizer".setup(user.plugin.colorizer())
end
