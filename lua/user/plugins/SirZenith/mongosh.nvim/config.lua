local user = require "user"
local hilight = require "user.config.general.highlight"

local color = hilight.color

user.plugin.mongosh_nvim = {
    __new_entry = true,

    query = {
        use_typed_query = true,
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
    require "mongosh-nvim".setup(user.plugin.mongosh_nvim())
end
