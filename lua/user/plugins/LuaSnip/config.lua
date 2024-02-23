local user = require "user"

user.plugin.luasnip = {
    __default = true,
    history = true,
    -- Update more often, :h events for more info.
    updateevents = "TextChanged,TextChangedI",
    ext_opts = {},
    -- treesitter-hl has 100, use something higher (default is 200).
    ext_base_prio = 300,
    -- minimal increase in priority.
    ext_prio_increase = 1,
    enable_autosnippets = true,
    store_selection_keys = "<Tab>",
}

return user.plugin.luasnip:with_wrap(function(value)
    local luasnip = require "luasnip"
    local types = require "luasnip.util.types"

    value.ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { "●", "LuaSnipChoiceHint" } },
            },
        },
        [types.insertNode] = {
            active = {
                virt_text = { { "●", "LuaSnipInsertHint" } }
            }
        }
    }

    luasnip.config.set_config(value)
end)
