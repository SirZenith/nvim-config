local user = require "user"
local panelpal = require "panelpal"

user.plugin.panelpal_nvim = {
    __new_entry = false,
    default_position_for_new_window = panelpal.PanelPosition.right,
}

return user.plugin.panelpal_nvim:with_wrap(function(value)
    panelpal.setup(value)
end)
