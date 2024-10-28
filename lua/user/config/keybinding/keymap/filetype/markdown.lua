local keybinding_util = require "user.config.keybinding.util"
local util = require "user.util"

---@param bufnr integer
return function(bufnr)
    local keymap = {
        v = {
            ["<A-b>"] = function()
                util.wrap_selected_text_with("<b>", "</b>")
            end,
            ["<A-u>"] = function()
                util.wrap_selected_text_with("<u>", "</u>")
            end,
        },
    }

    for mode, map_tbl in pairs(keymap) do
        for from, to in pairs(map_tbl) do
            keybinding_util.map(mode, from, to, { buffer = bufnr })
        end
    end
end
