---@type table<string, user.plugin.FormatterInfo | fun(bufnr: integer): user.plugin.FormatterInfo>
local tbl = {
    ["prettier-eslint"] = {
        command = vim.fn.has("win32") == 1 and "prettier-eslint.cmd" or "prettier-eslint",
        args = { "--stdin", "--stdin-filepath", "$FILENAME" },
    },
}

return tbl
