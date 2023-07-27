local fineline = require "fine-cmdline"

vim.keymap.set("n", "<leader><Cr>", function()
    fineline.open()
end)
