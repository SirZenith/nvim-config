---@type table<string, user.plugin.FormatterInfo | fun(bufnr: integer): user.plugin.FormatterInfo>
local tbl = {
    prettier_d_slim = {
        command = vim.fn.has("win32") == 1 and "prettier_d_slim.cmd" or "prettier_d_slim",
        args = { "--stdin", "--stdin-filepath", "$FILENAME" },
    },
    ["prettier-eslint"] = {
        command = vim.fn.has("win32") == 1 and "prettier-eslint.cmd" or "prettier-eslint",
        args = { "--stdin", "--stdin-filepath", "$FILENAME" },
    },
}

return tbl
