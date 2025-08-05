---@type vim.lsp.Config
local M = {
    cmd = { "vscode-markdown-language-server", "--stdio" },
    filetypes = { "markdown" },
    root_markers = { ".git" },
    single_file_support = true,
    settings = {},
    init_options = {
        markdownFileExtensions = { "md" },
    },
}

return M
