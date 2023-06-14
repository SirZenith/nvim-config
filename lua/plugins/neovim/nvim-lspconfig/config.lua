local user = require "user"
local lspconfig = require "user.language-server"
local nvim_lsp = require "lspconfig"

local lsp_servers = {
    "bashls",
    "clangd",

    -- nuget config -set http_proxy=http://127.0.0.1:1080
    -- dotnet tool install --global csharp-ls
    "csharp_ls",

    "cssls",
    "gopls",
    "hls",
    "html",
    -- npm i -g vscode-langservers-extracted
    "jsonls",
    -- pip install python-lsp-server
    -- pip install pylsp-mypy
    -- pip install python-lsp-black
    -- pip install python-lsp-ruff
    "pylsp",
    "rust_analyzer",
    "lua_ls",

    -- XML LS by Red Hat
    -- https://github.com/redhat-developer/vscode-xml/releases
    "lemminx",

    -- TypeScript/JavaScript Server
    -- install with:
    -- npm install -g typescript typescript-language-server
    "tsserver",
    "texlab",
    "vls",
}

local config_map = {}
for i = 1, #lsp_servers do
    local server = lsp_servers[i]
    local config = lspconfig.lsp_get_opt(server)
    config_map[server] = config
end

user.nvim_lspconfig.lsp_servers = lsp_servers
user.nvim_lspconfig.config = config_map

return function()
    local servers = user.nvim_lspconfig.lsp_servers()
    for i = 1, #servers do
        local server = servers[i]
        local config = user.nvim_lspconfig.config[server]()
        nvim_lsp[server].setup(config)
    end
end
