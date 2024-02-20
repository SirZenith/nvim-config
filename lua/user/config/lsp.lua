local user = require "user"
local config_const = require "user.config.constant"
local fs = require "user.utils.fs"

user.lsp = {
    __new_entry = true,
    root_path = fs.path_join(user.env.USER_RUNTIME_PATH(), "user", "lsp-configs"),
    log_update_method = "append",
    log_scroll_method = "bottom",
    on_attach_callbacks = {},
    capabilities_settings = {
        {
            textDocument = {
                foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                },
            },
        },
    },
    format_args = {
        async = true
    },
    keymap = {
        -- utility
        ["<A-F>"] = function() vim.lsp.buf.format(user.lsp.format_args()) end,
        ["<F2>"] = vim.lsp.buf.rename,
        ["<space>ca"] = vim.lsp.buf.code_action,
        -- goto
        ["gd"] = vim.lsp.buf.definition,
        ["gD"] = vim.lsp.buf.declaration,
        ["gr"] = vim.lsp.buf.references,
        ["gi"] = vim.lsp.buf.implementation,
        -- diagnostic
        ["<A-n>"] = vim.diagnostic.goto_prev,
        ["<A-.>"] = vim.diagnostic.goto_next,
        ["<space>d"] = vim.diagnostic.setloclist,
        ["<space>e"] = vim.diagnostic.open_float,
        -- hover & detail
        ["K"] = vim.lsp.buf.hover,
        ["<C-k>"] = vim.lsp.buf.signature_help,
        ["<space>D"] = vim.lsp.buf.type_definition,
        -- workspace
        ["<space>wa"] = vim.lsp.buf.add_workspace_folder,
        ["<space>wr"] = vim.lsp.buf.remove_workspace_folder,
        ["<space>wl"] = function()
            local paths = {}
            for _, path in ipairs(vim.lsp.buf.list_workspace_folders()) do
                table.insert(paths, vim.fs.normalize(path))
            end

            local msg = table.concat(paths, ",\n")
            vim.notify(msg)
        end,
    },
    kind_label = config_const.KIND_LABEL,
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
            desc = {
                "Language Server for OpenGL Shading Language",
            },
            install = "GitHub release page https://github.com/nolanderc/glsl_analyzer/releases",
        },
        {
            "gopls",
            install = "go install golang.org/x/tools/gopls@latest",
        },
        {
            "hls",
            desc = {
                "Haskell Language Server",
                "installation guide at:",
                "https://haskell-language-server.readthedocs.io/en/latest/installation.html",
            },
            install = "ghcup install hls",
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
            "nushell",
            desc = "make use of built in language server of nu",
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
            "taplo",
            desc = {
                "Language server for Taplo, a TOML toolkit",
            },
            install = "cargo install --features lsp --locked taplo-cli",
        },
        {
            "tsserver",
            enabled = false,
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
            desc = "V Language Server",
            install = {
                from_binary = {
                    "mkdir temp",
                    "curl 'https://raw.githubusercontent.com/vlang/v-analyzer/main/install.vsh' -o temp/install.vsh",
                    "v temp/install.sh",
                    "rm -r temp",
                },
                from_source = {
                    "git clone --recurse-submodules 'https://github.com/vlang/v-analyzer.git'",
                    "cd v-analyzer",
                    "v build.vsh release",
                },
            }
        },
        {
            "zls",
            desc = {
                "Zig Language Server",
                "installation guide at:",
                "https://github.com/zigtools/zls#installation",
            },
        },
    },
    load_extra_plugins = {},
}
