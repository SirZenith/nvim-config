local user = require "user"

user.nvim_treesitter = {
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
        "help",
        "html",
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
            init_selection = "<leader>g",
            node_incremental = "<leader>gl",
            scope_incremental = "<leader>g;",
            node_decremental = "<leader>ga",
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
    rainbow = {
        enable = true,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        colors = { "#6c9ef8", "#d85896", "#b77fdb", "#ef5350", "#64b5f6", "#ffee58", "#ab47bc" }, -- table of hex strings
        -- termcolors = {}, -- table of colour name strings
    },
}

local function register_debug_parser()
    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
    parser_config.v = {
        install_info = {
            url = "~/Developer/vls/tree_sitter_v", -- local path or git repo
            files = { "src/parser.c", "src/scanner.c" },
            generate_requires_npm = false,
            requires_generate_from_grammar = true,
        },
        filetype = "vlang",
    }
end

return function()
    local augroup = vim.api.nvim_create_augroup("user.treesitter", { clear = true })
    -- 去除 markdown 中代码块的斜体
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "markdown",
        callback = function()
            local name = "MarkdownText"
            vim.api.nvim_set_hl(0, name, {})
            vim.api.nvim_set_hl(0, "@text.literal", { link = name })
        end,
    })

    if user.nvim_treesitter.debug() then
        register_debug_parser()
    end

    require 'nvim-treesitter.configs'.setup(user.nvim_treesitter())
end
