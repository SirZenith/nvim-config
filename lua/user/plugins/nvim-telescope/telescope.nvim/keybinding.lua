local set = vim.keymap.set

return function()
    set("n", "<leader>f", "<cmd>Telescope find_files<cr>")
    set("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
end
