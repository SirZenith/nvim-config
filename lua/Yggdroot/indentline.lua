local user = require "user"

user.g = {
    -- 激活 indentLine 对 conceal 颜色设定的功能
    indentLine_setColors = true,
    indentLine_color_term = 239,
    indentLine_color_gui = "#7AB0B5",
    indentLine_char_list = { "|", "¦", "┆", "┊" },
    -- 关闭 indentLine 对 conceal level 的修改
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
