local user = require "user"

user.plugin.nvim_treesitter = {
    __newentry = true,
    configs = {
        ---@type "all" | "maintained" | string[]
        ensure_installed = {
            "bash",
            "bibtex",
            "c",
            "clojure",
            "cmake",
            -- "comment", -- disable due to performance problem
            "cpp",
            "c_sharp",
            "css",
            -- "dap_repl",
            "devicetree",
            "dot",
            "gitignore",
            "gleam",
            "glsl",
            "go",
            "gomod",
            "haskell",
            "html",
            "hyprlang",
            "ini",
            "javascript",
            "json",
            "kotlin",
            "latex",
            "lua",
            "make",
            "markdown",
            "markdown_inline",
            "python",
            "qmljs",
            "query",
            "rasi",
            "regex",
            "rust",
            "sql",
            "toml",
            "typescript",
            "v",
            "vim",
            "vimdoc",
            "yaml",
            "zig",
        },

        -- Install languages synchronously (only applied to `ensure_installed`)
        ---@type boolean
        sync_install = false,

        -- List of parsers to ignore installing
        ---@type string[]
        ignore_install = {},

        -- --------------------------------------------------------------------
        -- Extensions
        highlight = {
            enable = true,

            -- list of language that will be disabled
            ---@type string[]
            disable = {},

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            -- set keymap value to `false` to disable mappings
            ---@type table<string, string | false>
            keymaps = {
                init_selection = "<Backspace>g",
                node_incremental = "gj",
                node_decremental = "gk",
                scope_incremental = "g<Cr>",
            },
        },
        indent = {
            enable = true,
        },
        playground = {
            enable = true,
            keybindings = {
                toggle_query_editor = 'o',
                toggle_hl_groups = 'i',
                toggle_injected_languages = 't',
                toggle_anonymous_nodes = 'a',
                toggle_language_display = 'I',
                focus_language = 'f',
                unfocus_language = 'F',
                update = 'R',
                goto_node = '<cr>',
                show_help = '?',
            },
        },
        query_linter = {
            enable = true,
            use_virtual_text = true,
            lint_events = { "BufWrite", "CursorHold" },
        },
        textobjects = {
            enable = true,
        },
    },
    install = {
        prefer_git = false,
        compilers = { "cl", "clang", "gcc", "cc", "zig" },
        command_extra_args = {
            cl = { "/nologo" },
            curl = { "-x", user.env.PROXY_URL() },
        },
    },
    parsers = {},
}

local env_cc = user.env.CC()
if env_cc ~= "cc" then
    user.plugin.nvim_treesitter.install.compilers:prepend(env_cc)
end

return user.plugin.nvim_treesitter:with_wrap(function(value)
    local nts_configs = require "nvim-treesitter.configs"
    local nts_parsers = require "nvim-treesitter.parsers"
    local nts_install = require "nvim-treesitter.install"

    local augroup = vim.api.nvim_create_augroup("user.plugin.nvim_treesitter", { clear = true })
    -- remote italic in markdown code block
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "markdown",
        callback = function()
            local name = "MarkdownText"
            vim.api.nvim_set_hl(0, name, {})
            vim.api.nvim_set_hl(0, "@text.literal", { link = name })
        end,
    })

    -- ------------------------------------------------------------------------

    nts_configs.setup(value.configs)

    -- ------------------------------------------------------------------------

    nts_install.prefer_git = value.install.prefer_git

    local compilers = value.install.compilers
    if compilers then
        nts_install.compilers = compilers
    end

    nts_install.command_extra_args = vim.tbl_extend(
        "force",
        nts_install.command_extra_args,
        value.install.command_extra_args
    )

    -- ------------------------------------------------------------------------

    local parser_config = nts_parsers.get_parser_configs()
    for name, info in pairs(value.parsers) do
        parser_config[name] = info
    end
end)
