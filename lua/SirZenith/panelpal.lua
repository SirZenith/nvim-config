local user = require "user"
local panelpal = require "panelpal"

user.panelpal = {
    default_position_for_new_window = panelpal.PanelPosition.right,
}

return function()
    panelpal.setup(user.panelpal())
end
