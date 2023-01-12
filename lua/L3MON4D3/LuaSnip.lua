local user = require "user"
local ls = require("luasnip")
local types = require("luasnip.util.types")

user.LuaSnip = {
    history = true,
    -- Update more often, :h events for more info.
    updateevents = "TextChanged,TextChangedI",
    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { "choiceNode", "Comment" } },
            },
        },
    },
    -- treesitter-hl has 100, use something higher (default is 200).
    ext_base_prio = 300,
    -- minimal increase in priority.
    ext_prio_increase = 1,
    enable_autosnippets = true,
    store_selection_keys = "<Tab>",
}

return function()
    -- Every unspecified option will be set to the default.
    ls.config.set_config(user.LuaSnip())
end
