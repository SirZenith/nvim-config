local user = require "user"

--[[ legazy
--{
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
            "nu",
            "python",
            "qmljs",
            "query",
            "rasi",
            "regex",
            "ron",
            "rust",
            "scss",
            "sql",
            "toml",
            "typescript",
            "v",
            "vim",
            "vimdoc",
            "yaml",
            "yuck", -- configuration language for eww
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
]]

user.plugin.nvim_treesitter = {
    __newentry = true,
    languages = {
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
        "nu",
        "python",
        "qmljs",
        "query",
        "rasi",
        "regex",
        "ron",
        "rust",
        "scss",
        "sql",
        "toml",
        "typescript",
        "v",
        "vim",
        "vimdoc",
        "yaml",
        "yuck", -- configuration language for eww
        "zig",
    },
    ---@type ParserInfo
    parsers = {},
}

local env_cc = user.env.CC()
if env_cc ~= "cc" then
    user.plugin.nvim_treesitter.install.compilers:prepend(env_cc)
end

return user.plugin.nvim_treesitter:with_wrap(function(value)
    local nts = require "nvim-treesitter"
    local nts_parsers = require "nvim-treesitter.parsers"

    -- ------------------------------------------------------------------------

    local augroup_name = "user.plugin.nvim_treesitter"
    local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

    local filetypes = {}
    for _, lang in ipairs(value.languages) do
        local list = vim.treesitter.language.get_filetypes(lang)
        vim.list_extend(filetypes, list)
    end

    -- activate treesitter functionality
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = filetypes,
        callback = function()
            -- indentation
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            -- syntax highlighting
            vim.treesitter.start()
        end,
    })

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

    nts.install(value.languages)

    -- ------------------------------------------------------------------------

    for name, info in pairs(value.parsers) do
        nts_parsers[name] = info
    end
end)
