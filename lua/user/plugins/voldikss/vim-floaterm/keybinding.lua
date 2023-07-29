local set = vim.keymap.set

return function()
    for _, mode in ipairs { "n", "i", "t", "v" } do
        set(mode, "<F12>", "<cmd>FloatermToggle<cr>")
    end
end
