local user = require "user"

user.plugin.panelpal_nvim = {
    __new_entry = false,
    default_position_for_new_window = "right",
}

return user.plugin.panelpal_nvim:with_wrap(function(value)
    require "panelpal".setup(value)
end)
