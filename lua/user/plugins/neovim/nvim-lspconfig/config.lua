local user = require "user"
local ls_configs = require "user.language-server.configs"

local nvim_lsp = require "lspconfig"

local function get_name(info)
    return type(info) == "string" and info or info[1]
end

user.plugin.nvim_lspconfig = {
    __new_entry = true,
    config = {},
    lsp_servers = {
        "bashls",
        "clangd",
        {
            "csharp_ls",
            install = {
                "nuget config -set http_proxy=http://127.0.0.1:1080",
                "dotnet tool install --global csharp-ls",
            }
        },
        "cssls",
        "gopls",
        "hls",
        "html",
        {
            "jsonls",
            install = "npm i -g vscode-langservers-extracted",
        },
        {
            "pylsp",
            install = {
                "pip install python-lsp-server",
                "pip install pylsp-mypy",
                "pip install python-lsp-black",
                "pip install python-lsp-ruff",
            },
        },
        "rust_analyzer",
        "lua_ls",
        {
            "lemminx",
            desc = {
                "XML LS by Red Hat",
                "https://github.com/redhat-developer/vscode-xml/releases",
            }
        },
        {
            "tsserver",
            desc = "TypeScript/JavaScript Server",
            install = "npm install -g typescript typescript-language-server",
        },
        "texlab",
        "vls",
    },
}

return function()
    for _, info in user.plugin.nvim_lspconfig.lsp_servers:ipairs() do
        local server = get_name(info)
        ls_configs.setup_lsp(
            server,
            user.plugin.nvim_lspconfig.config[server]() or {}
        )
    end
end
