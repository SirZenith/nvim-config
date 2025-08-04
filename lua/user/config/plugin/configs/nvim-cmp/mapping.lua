local cmp = require "cmp"
local luasnip = require "luasnip"

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then
        return false
    end
    local cursor_line = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    local last_char = cursor_line:sub(col, col)
    return last_char ~= " " and last_char ~= "\t" and last_char ~= "\v"
end

return {
    ["<tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
        elseif has_words_before() then
            cmp.complete()
        else
            fallback()
        end
    end, { "c", "i", "s" }),
    ["<S-tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end, { "c", "i", "s" }),
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ["<cr>"] = cmp.mapping.confirm { select = false },
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-y>"] = cmp.config.disable,
    -- Trigger/close completion
    ["<C-j>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-k>"] = cmp.mapping {
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
    },
}
