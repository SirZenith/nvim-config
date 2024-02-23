local user = require "user"

user.plugin.nvim_surround = {
    __default = true,
    -- Built-in delimiters include:
    -- - (), [], {}, <>, '', "", triggered by either side of delimiter.
    -- - HTML tags, triggered by `t` or `T`, e.g. `ysiwt`, tag name is given by
    --   input box.
    -- - Function call, triggered by `f`, e.g. `ysiwf`, function name is given
    --   by input box.

    keymaps = {
        -- `_line` suffix means insert a new line in between delimiters.
        -- One can use this variation to quickly spread function arguments to
        -- multiple lines.
        --
        -- `_cur` suffix means current line

        -- Insert paried delimiters around cursor.
        insert = "<C-g>s",
        insert_line = "<C-g>S",

        -- Add delimiters around selection.
        visual = "S",
        visual_line = "gS",

        -- Add delimiters by motion range, usage: `ys{motion}{delimiter}`, see
        -- |motion.txt|.
        normal = "<leader>s",
        normal_line = "<leader>S",

        -- Add delimiters around current line
        normal_cur = "<leader>ss",
        normal_cur_line = "<leader>SS",

        -- Delete specified delimiters, usage: `ds{delimiter}`
        delete = "ds",

        -- Change delimiters, usage: `cs{from-delimiter}{to-delimiter}`
        change = "cs",
        change_line = "cS",
    },
}

return user.plugin.nvim_surround:with_wrap(function(value)
    require "nvim-surround".setup(value)
end)
