local user = require "user"

user.pandoc_syntax.markdown_code_langs = {
    "asm",
    "arch",
    "arduino",
    "bash",
    "bib",
    "c",
    "cabal",
    "cmake",
    "cpp",
    "crontab",
    "csharp",
    "css",
    "dot",
    "go",
    "haskell",
    "html",
    "javascript",
    "json",
    "kotlin",
    "lua",
    "matlab",
    "plaintex",
    "plantuml",
    "python",
    "rust",
    "vim",
    "yaml",
}

user.pandoc_syntax.enabled_features = {
    "formatting", "folding", "toc", "command", "menu",
    "bibliographies", "completion", "keyboard",
}

return function()
    local pandoc_group = vim.api.nvim_create_augroup("pandoc.syntax", { clear = true })
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
        group = pandoc_group,
        pattern = "*.md",
        command = "set filetype=markdown.pandoc"
    })

    vim.g["pandoc#syntax#codeblocks#embeds#langs"] = user.pandoc_syntax.markdown_code_langs()
    vim.g["pandoc#modules#enabled"] = user.pandoc_syntax.enabled_features()
end
