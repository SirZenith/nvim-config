local set = vim.keymap.set

return function()
    set("n", "<space>sb", "<cmd>NvimTreeToggle<cr>")
    set("n", "<leader>tr", "<cmd>NvimTreeRefresh<cr>")
    set("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>")
end
