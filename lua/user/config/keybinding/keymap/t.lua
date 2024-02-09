local keybinding_util = require "user.config.keybinding.util"

return vim.tbl_extend("keep", {
    ["<C-y>"] = "<C-\\><C-n>",
}, {
    -- ------------------------------------------------------------------------
    -- Terminal toggle
    ["<C-p>"] = keybinding_util.toggle_terminal,
})
