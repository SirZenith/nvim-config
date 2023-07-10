local user = require "user"
local lspconfig = require "user.language-server"
local nvim_lsp = require "lspconfig"

local function get_name(info)
    return type(info) == "string" and info or info[1]
end

local lsp_servers = {
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
}

local config_map = {}
for i = 1, #lsp_servers do
    local server = get_name(lsp_servers[i])
    local config = lspconfig.lsp_get_opt(server)
    config_map[server] = config
end

user.plugin.nvim_lspconfig = {
    __new_entry = true,

    lsp_servers = lsp_servers,
    config = config_map,
}

return function()
    local servers = user.plugin.nvim_lspconfig.lsp_servers()
    for i = 1, #servers do
        local server = get_name(servers[i])
        local config = user.plugin.nvim_lspconfig.config[server]() or {}
        nvim_lsp[server].setup(config)
    end
end
