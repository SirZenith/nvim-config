local user = require "user"

user.platform.im_select = {
    check = "fcitx5-remote",
    on = "fcitx5-remote -o",
    off = "fcitx5-remote -c",
    isoff = function(im)
        return tonumber(im) == 1
    end
}
