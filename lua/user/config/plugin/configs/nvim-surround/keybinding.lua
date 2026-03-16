return function()
    local set = vim.keymap.set

    -- `_line` suffix means insert a new line in between delimiters.
    -- One can use this variation to quickly spread function arguments to
    -- multiple lines.
    --
    -- `_cur` suffix means current line

    set("i", "<C-g>s", "<Plug>(nvim-surround-insert)", {
        desc = "Insert paried delimiters around cursor.",
    })
    set("i", "<C-g>S", "<Plug>(nvim-surround-insert-line)", {
        desc = "Insert paried delimiters around cursor.",
    })

    set("v", "S", "<Plug>(nvim-surround-visual)", {
        desc = "Add delimiters around selection.",
    })
    set("v", "gS", "<Plug>(nvim-surround-visual-line)", {
        desc = "Add delimiters around selection.",
    })

    set("n", "<leader>s", "<Plug>(nvim-surround-normal)", {
        desc = "Add delimiters by motion range, usage: `ys{motion}{delimiter}`, see |motion.txt|.",
    })
    set("n", "<leader>S", "<Plug>(nvim-surround-normal-ine)", {
        desc = "Add delimiters by motion range, usage: `ys{motion}{delimiter}`, see |motion.txt|.",
    })

    set("n", "<leader>ss", "<Plug>(nvim-surround-normal-cur)", {
        desc = "Add delimiters around current line",
    })
    set("n", "<leader>SS", "<Plug>(nvim-surround-normal-cur-line)", {
        desc = "Add delimiters around current line",
    })

    set("n", "ds", "<Plug>(nvim-surround-delete)", {
        desc = "Delete specified delimiters, usage: `ds{delimiter}`",
    })

    set("n", "cs", "<Plug>(nvim-surround-change)", {
        desc = "Change delimiters, usage: `cs{from-delimiter}{to-delimiter}`",
    })
    set("n", "cS", "<Plug>(nvim-surround-change-line)", {
        desc = "Change delimiters, usage: `cs{from-delimiter}{to-delimiter}`",
    })
end
