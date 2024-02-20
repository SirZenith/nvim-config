return function()
    local conform = require "conform"

    vim.keymap.set("n", "<A-F>", function()
        conform.format {
            bufnr = 0,
            async = true,
            lsp_fallback = true,
        }
    end)
end
