local user = require "user"
local panelpal = require "panelpal"

user.plugin.panelpal = {
    __new_entry = false,
    default_position_for_new_window = panelpal.PanelPosition.right,
}

return function()
    panelpal.setup(user.plugin.panelpal())
end
