return function()
    local conform = require "conform"

    vim.keymap.set("n", "<A-F>", conform.format)
end
