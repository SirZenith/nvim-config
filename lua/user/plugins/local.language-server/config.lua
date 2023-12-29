local user = require "user"

local function get_name(info)
    return type(info) == "string" and info or info[1]
end

user.lsp = {
    __new_entry = true,
    log_update_method = "append",
    log_scroll_method = "bottom",
    on_attach_callbacks = {},
    capabilities_settings = {
        vim.lsp.protocol.make_client_capabilities()
    },
    format_args = {
        async = true
    },
    kind_label = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
    },
    server_config = {},
    server_list = {
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
            enable = false,
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
    local panelpal = require "panelpal"
    local lspconfig = require "lspconfig"
    local ls_configs = require "user-lsp.configs"

    user.lsp.log_update_method = panelpal.PanelContentUpdateMethod.append
    user.lsp.log_scroll_method = panelpal.ScrollMethod.bottom


    for _, info in user.lsp.server_list:ipairs() do
        if info.enable ~= false then
            local server = get_name(info)

            local stock_config = lspconfig[server]
            local document_config = stock_config and stock_config.document_config
            local default_config = document_config and document_config.default_config
            local old_on_new_config = default_config and default_config.on_new_config

            lspconfig[server].setup {
                on_new_config = function(config, root_dir)
                    if type(old_on_new_config) == "function" then
                        old_on_new_config(config, root_dir)
                    end

                    local user_config = ls_configs.load(
                        server,
                        user.lsp.server_config[server]() or {}
                    )

                    for k, v in pairs(user_config) do
                        config[k] = v
                    end
                end,
            }
        end
    end
end
