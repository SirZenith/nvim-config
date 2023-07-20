local user = require "user"

user.option.g = {
    -- let indentLine to set conceal color
    indentLine_setColors = true,
    indentLine_color_term = 239,
    indentLine_color_gui = "#7AB0B5",
    indentLine_char_list = { "|", "¦", "┆", "┊" },
    -- disable conceal level modifying of indentLine
    indentLine_setConceal = false,
}

return function()
    --[[
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "tex" },
        callback = function()
            vim.g.indentLine_setConceal = false
        end
    })
    ]]
end
