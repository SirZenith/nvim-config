return function()
    local set = vim.keymap.set

    set("n", "<leader>p", "<cmd>Telescope neoclip<cr>")
end
