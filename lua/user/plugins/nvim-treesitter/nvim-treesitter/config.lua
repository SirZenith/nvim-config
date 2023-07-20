local user = require "user"
local table_utils = require "user.utils.table"

local nts_configs = require "nvim-treesitter.configs"
local nts_parsers = require "nvim-treesitter.parsers"
local nts_install = require "nvim-treesitter.install"

user.plugin.nvim_treesitter = {
    __new_entry = true,
    configs = {
        -- One of "all", "maintained" (parsers with maintainers), or a list of languages
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
            "dot",
            "gitignore",
            "go",
            "gomod",
            "haskell",
            "html",
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
            "query",
            "regex",
            "rust",
            "sql",
            "toml",
            "typescript",
            "v",
            "vim",
            "yaml",
        },
        -- Install languages synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- List of parsers to ignore installing
        -- ignore_install = { "javascript" },

        highlight = {
            -- `false` will disable the whole extension
            enable = true,
            -- list of language that will be disabled
            -- disable = { "latex" },

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                -- set to `false` to disable one of the mappings
                init_selection = "<Backspace>g",
                node_incremental = "<Backspace>gl",
                scope_incremental = "<Backspace>g;",
                node_decremental = "<Backspace>ga",
            },
        },
        indent = {
            -- enable = true,
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
        rainbow = {
            enable = true,
            -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
            extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = nil, -- Do not enable for files with more than n lines, int
            colors = { "#6c9ef8", "#d85896", "#b77fdb", "#ef5350", "#64b5f6", "#ffee58", "#ab47bc" }, -- table of hex strings
            -- termcolors = {}, -- table of colour name strings
        },
        -- autotag = {
            -- enable = true,
        -- }
    },
    install = {
        prefer_git = false,
        compilers = { vim.env.CC, "cl", "clang", "gcc", "cc", "zig" },
        command_extra_args = {
            cl = { "/nologo" },
            curl = { "-x", user.env.PROXY_URL() },
        },
    },
    parsers = {
        nu = {
            install_info = {
                url = "https://github.com/nushell/tree-sitter-nu",
                files = { "src/parser.c" },
                branch = "main",
            },
            filetype = "nu",
        },
    },
}

return function()
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

    nts_configs.setup(user.plugin.nvim_treesitter.configs())

    -- ------------------------------------------------------------------------

    nts_install.prefer_git = user.plugin.nvim_treesitter.install.prefer_git()

    local compilers = user.plugin.nvim_treesitter.install.compilers()
    if compilers then
        nts_install.compilers = compilers
    end

    table_utils.update_table(
        nts_install.command_extra_args,
        user.plugin.nvim_treesitter.install.command_extra_args()
    )

    -- ------------------------------------------------------------------------

    local parser_config = nts_parsers.get_parser_configs()
    for name, info in user.plugin.nvim_treesitter.parsers:pairs() do
        parser_config[name] = info
    end
end
