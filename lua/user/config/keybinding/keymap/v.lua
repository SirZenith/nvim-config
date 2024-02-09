local keybinding_util = require "user.config.keybinding.util"

return vim.tbl_extend("keep", {
    -- ------------------------------------------------------------------------
    ["<C-y>"] = "<esc>",
}, {
    -- ------------------------------------------------------------------------
    -- Editing
    ["<leader>p"] = "\"_dP",
    ["<leader>d"] = "\"_d",
}, {
    -- ------------------------------------------------------------------------
    -- Movement
    ["<leader>h"] = "^",
    ["<leader>l"] = "$",
    ["<leader>j"] = "+",
    ["<leader>k"] = "-",
}, {
    -- ------------------------------------------------------------------------
    -- Searching
    ["<leader>sg"] = function()
        local panelpal = require "panelpal"

        local target = panelpal.visual_selection_text()
        if not target or #target == 0 then return end
        keybinding_util.global_search(target)
    end,
})
