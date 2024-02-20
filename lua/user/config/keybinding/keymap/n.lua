local keybinding_util = require "user.config.keybinding.util"

local api = vim.api

return vim.tbl_extend("keep", {
    -- ------------------------------------------------------------------------
    -- Tab management
    -- new tab
    ["<C-n>"] = "<cmd>tabnew<cr>",
    -- close tab
    ["<A-w>"] = keybinding_util.close_all_win_in_cur_tab,
}, {
    -- ------------------------------------------------------------------------
    -- Editing
    ["<C-s>"] = "<cmd>w<cr>",
    ["dal"] = "0d$",
    [";;"] = function()
        keybinding_util.append_to_eol { ";" }
    end,
    [",,"] = function()
        keybinding_util.append_to_eol { "," }
    end,
    ["<backspace>e"] = function()
        -- move text one line up

        local pos = api.nvim_win_get_cursor(0)
        local row = pos[1] - 1
        if row <= 0 then
            return
        end

        local lines = api.nvim_buf_get_lines(0, row - 1, row + 1, true)
        lines[1], lines[2] = lines[2], lines[1]

        api.nvim_buf_set_lines(0, row - 1, row + 1, true, lines)
        pos[1] = row
        api.nvim_win_set_cursor(0, pos)
    end,
    ["<backspace>d"] = function()
        -- move text one line down

        local line_cnt = vim.fn.getpos("$")[2]
        local pos = api.nvim_win_get_cursor(0)
        local row = pos[1]
        if row >= line_cnt then
            return
        end

        local lines = api.nvim_buf_get_lines(0, row - 1, row + 1, true)
        lines[1], lines[2] = lines[2], lines[1]

        api.nvim_buf_set_lines(0, row - 1, row + 1, true, lines)
        pos[1] = row + 1
        api.nvim_win_set_cursor(0, pos)
    end,
}, {
    -- ------------------------------------------------------------------------
    -- Folding
    ["<Tab>"] = "za",
}, {
    -- ------------------------------------------------------------------------
    -- Searching
    ["<leader>sg"] = function()
        local target = vim.fn.input({ prompt = "Global Search: " })
        if not target or #target == 0 then return end
        keybinding_util.global_search(target)
    end,
}, {
    -- ------------------------------------------------------------------------
    -- Window
    -- Moving windows
    ["<A-C-h>"] = "<C-w>H",
    ["<A-C-j>"] = "<C-w>J",
    ["<A-C-k>"] = "<C-w>K",
    ["<A-C-l>"] = "<C-w>L",
    -- Window size adjustment
    [";s"] = "<C-w><",
    [";f"] = "<C-w>>",
    [";e"] = "<C-w>+",
    [";d"] = "<C-w>-",
}, {
    -- ------------------------------------------------------------------------
    -- Toggling windows
    -- Quickfix window
    ["<leader><backspace>"] = keybinding_util.toggle_quickfix,
    -- terminal window
    ["<C-p>"] = keybinding_util.toggle_terminal,

}, {
    -- ------------------------------------------------------------------------
    -- Moving
    -- moving between window splits
    ["<leader>n"] = "<C-w>h",
    ["<leader>."] = "<C-w>l",
    -- tab switching
    ["<leader>y"] = "gT",
    ["<leader>o"] = "gt",
    -- line movement
    ["<leader>h"] = "^",
    ["<leader>l"] = "$",
    ["<leader>j"] = "+",
    ["<leader>k"] = "-",
    -- page movement
    ["<C-d>"] = "<C-d>zz",
    ["<C-u>"] = "<C-u>zz",
    ["<C-f>"] = "<C-d>zz",
    ["<C-b>"] = "<C-b>zz",
}, {
    -- ------------------------------------------------------------------------
    -- Jumping
    -- jumping in history position
    ["<C-h>"] = "<C-o>",
    ["<C-l>"] = "<C-i>",
    -- Quick Fix jumping
    ["<A-j>"] = "<cmd>cnext<cr>zz",
    ["<A-k>"] = "<cmd>cprevious<cr>zz",
    -- jump to file
    ["gf"] = function() keybinding_util.goto_cursor_file(true) end,
    ["<leader>gf"] = function() keybinding_util.goto_cursor_file(false) end,
})
