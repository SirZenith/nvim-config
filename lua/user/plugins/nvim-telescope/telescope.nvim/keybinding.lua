return function()
    local set = vim.keymap.set

    set("n", "<leader>b", "<cmd>Telescope buffers<cr>")
    set("n", "<leader>f", "<cmd>Telescope find_files<cr>")
    set("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
end
