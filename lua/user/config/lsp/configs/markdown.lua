return {
    cmd = { "vscode-markdown-language-server", "--stdio" },
    filetypes = { "markdown" },
    root_dir = function()
        local lspconfig_util = require "lspconfig.util"
        return lspconfig_util.root_pattern(".git")()
    end,
    single_file_support = true,
    settings = {},
    init_options = {
        markdownFileExtensions = { "md" },
    },
}
