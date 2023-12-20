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
        {
            "bashls",
            install = "npm i -g bash-language-server",
        },
        {
            "clangd",
            desc = {
                "check out installation guide at:",
                "https://clangd.llvm.org/installation.html",
            },
        },
        {
            "csharp_ls",
            install = {
                "nuget config -set http_proxy=http://127.0.0.1:1080",
                "dotnet tool install --global csharp-ls",
            }
        },
        {
            "cssls",
            install = "npm i -g vscode-langservers-extracted",
        },
        {
            "glsl_analyzer",
            install = "GitHub release page https://github.com/nolanderc/glsl_analyzer/releases",
        },
        {
            "gopls",
            install = "go install golang.org/x/tools/gopls@latest",
        },
        {
            "hls",
            install = "ghcup install hls",
            desc = {
                "installation guide at:",
                "https://haskell-language-server.readthedocs.io/en/latest/installation.html",
            },
        },
        {
            "html",
            install = "npm i -g vscode-langservers-extracted",
        },
        {
            "jsonls",
            install = "npm i -g vscode-langservers-extracted",
        },
        {
            "pylsp",
            install = "pip install 'python-lsp-server[all]'",
        },
        {
            "rust_analyzer",
            desc = {
                "installation guide at:",
                "https://rust-analyzer.github.io/manual.html#installation",
            }
        },
        {
            "lua_ls",
            desc = {
                "repo URL: https://github.com/luals/lua-language-server",
            }
        },
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
        {
            "texlab",
            desc = {
                "repo URL: https://github.com/latex-lsp/texlab",
                "recommended to build from source",
            },
        },
        -- "vls",
        {
            "v_analyzer",
            install = {
                "mkdir temp",
                "curl 'https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh' -o temp/install.vsh",
                "v temp/install.sh",
                "rm -r temp",
            }
        },
        {
            "zls",
            desc = {
                "installation guide at:",
                "https://github.com/zigtools/zls#installation",
            },
        },
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
