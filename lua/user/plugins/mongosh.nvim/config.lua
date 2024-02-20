local user = require "user"
local hilight = require "user.config.general.highlight"

local color = hilight.color

user.plugin.mongosh_nvim = {
    __new_entry = true,

    query = {
        use_typed_query = false,
        result_style = "card",
    },

    card_view = {
        indent_colors = {
            color.magenta.normal,
            color.blue.normal,
            color.yellow.normal,
            color.cyan.normal,
            color.orange.normal,
            color.green.normal,
            color.red.normal
        },

        card = {
            min_content_width = 50,
        }
    },
}

return function()
    local lualine = require "lualine"
    local mongosh = require "mongosh-nvim"
    local mongosh_status = require "mongosh-nvim.ui.status"

    user.plugin.lualine.sections.lualine_x:prepend(mongosh_status.status)
    user.plugin.lualine.inactive_sections.lualine_x:prepend(mongosh_status.status)

    mongosh.setup(user.plugin.mongosh_nvim())
    lualine.setup(user.plugin.lualine())
end
