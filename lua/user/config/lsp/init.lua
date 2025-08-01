local user = require "user"
local config_const = require "user.config.constant"
local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

user.lsp = {
    __newentry = true,

    kind_label = config_const.KIND_LABEL,
    log_update_method = "append",
    log_scroll_method = "bottom",

    ---@type boolean | fun(client: vim.lsp.Client, bufnr: integer): boolean
    use_inlay_hint = false,

    ---@type table[]
    capabilities_list = {},
    keymap = {
        -- utility
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

    ---@type (fun(client: vim.lsp.Client, bufnr: integer))[]
    on_attach_callbacks = {
        -- setup keymap
        function(_client, bufnr)
            local set = vim.keymap.set
            local opts = { noremap = true, silent = true, buffer = bufnr }
            for key, callback in user.lsp.keymap:pairs() do
                set("n", key, callback, opts)
            end
        end,

        -- try to turn on inlay hint
        function(client, bufnr)
            if not client.server_capabilities.inlayHintProvider then
                return
            end

            local checker = user.lsp.use_inlay_hint()
            local checker_type = type(checker)

            local is_on = false
            if checker_type == "boolean" then
                is_on = checker
            elseif checker_type == "function" then
                is_on = checker(client, bufnr)
            end

            vim.lsp.inlay_hint.enable(is_on, { bufnr = bufnr })
        end,
    },

    -- This field allows injecting configuration from workspace config
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
            "gleam",
            desc = "`gleam lsp` subcommand of Gleam compiler provides LSP support",
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
            "markdown",
            enabled = false,
            install = "yarn global add vscode-langservers-extracted",
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
            "qmlls",
            desc = "QML Language server shipping with QT",
            install = {
                "One can find package name something like `qt6-langaugeserver`",
                "install that package with package manager",
            },
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
            "vtsls",
            desc = "VSCode tsserver wrapper",
            install = {
                "npm install -g @vtsls/language-server",
            },
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

---@return table
local function merge_capabilities()
    local capabilities = {}

    for _, cap in user.lsp.capabilities_list:ipairs() do
        local cap_t = type(cap)
        if cap_t == "table" then
            capabilities = vim.tbl_extend("force", capabilities, cap)
        elseif cap_t == "function" then
            capabilities = vim.tbl_extend("force", capabilities, cap())
        end
    end

    return capabilities;
end

---@param config table
---@return table
local function wrap_on_attach(config)
    local on_attach = config.on_attach
    config.on_attach = function(client, bufnr)
        for _, callback in user.lsp.on_attach_callbacks:ipairs() do
            callback(client, bufnr)
        end

        if type(on_attach) == 'function' then
            on_attach(client, bufnr)
        end
    end

    return config
end

-- merging LSP config from different source.
---@param name string
local function merge_lsp_config(name)
    local loader = require "user.config.lsp.loader"

    local config_overlay = user.lsp.server_config[name]()
    if type(config_overlay) == "function" then
        config_overlay = config_overlay()
    end

    local root_path = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "config", "lsp", "configs")
    local config_module = loader.load(root_path, name)

    local result = vim.tbl_deep_extend(
        "force",
        {
            flags = {
                debounce_text_changes = 150,
            },
        },
        config_module,
        config_overlay or {},
        {
            capabilities = merge_capabilities(),
        }
    )

    return result
end

return function()
    require "user.config.lsp.command".init()

    for _, info in user.lsp.server_list:ipairs() do
        if info.enabled ~= false then
            local name = type(info) == "string" and info or info[1]

            local config = merge_lsp_config(name)
            config = wrap_on_attach(config)

            vim.lsp.config(name, config)
            vim.lsp.enable(name)
        end
    end
end
