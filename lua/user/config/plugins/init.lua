local putl = require "user.config.plugins.utils"

local ucs = putl.user_config_spec

putl.turn_on_true_color()

---@type (user.plugin.PluginSpec | string)[]
local specs = {
    -- ------------------------------------------------------------------------
    -- Local configs
    ucs "user.config.general",
    ucs "user.config.keybinding",
    ucs "user.config.command",
    ucs "user.config.platforms",
    ucs "user.config.lsp",
    ucs "user.workspace",

    -- ------------------------------------------------------------------------
    -- Themes
    { "marko-cerovac/material.nvim",      enabled = false },
    { "kaicataldo/material.vim",          enabled = false },
    { "EdenEast/nightfox.nvim" },
    { "shaunsingh/nord.nvim",             enabled = false },
    { "mhartington/oceanic-next",         enabled = false },
    { "JoosepAlviste/palenightfall.nvim", enabled = false },
    { "wadackel/vim-dogrun",              enabled = false },
    { "rakr/vim-two-firewatch",           enabled = false },

    -- ------------------------------------------------------------------------
    -- General
    {
        "numToStr/Comment.nvim",
        event = "BufReadPost",
    },
    {
        -- Collaborative edit support
        "jbyuki/instant.nvim",
        cmd = {
            "InstantStartServer",

            "InstantStartSingle",
            "InstantJoinSingle",

            "InstantStartSession",
            "InstantJoinSession",
        }
    },
    {
        -- Jump to anywhere with a few key strokes
        "ggandor/leap.nvim",
        -- enabled = false,
        event = "BufReadPost",
    },
    {
        -- Show bookmark symbols in gutter column.
        "chentoast/marks.nvim",
        event = "BufReadPost",
    },
    {
        -- Clipboard history manager
        "AckslD/nvim-neoclip.lua",
        requires = {
            -- you'll need at least one of these
            "nvim-telescope/telescope.nvim",
            -- "ibhagwan/fzf-lua",
        },
        event = "BufReadPost",
    },
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
    },
    {
        "kylechui/nvim-surround",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        event = "BufReadPost",
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
    },
    {
        "SirZenith/panelpal.nvim",
        -- dev = true,
        event = "VeryLazy",
    },
    {
        -- Global Search & Replace
        "nvim-pack/nvim-spectre",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        cmd = {
            "SearchAndReplace",
            "Spectre",
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
    },
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        dependencies = { "user.config.general" },
    },
    {
        'ThePrimeagen/vim-be-good',
        cmd = "VimBeGood",
    },
    {
        -- Markup language heading outline sidebar.
        "vim-voom/VOoM",
        ft = { "markdown", "html" },
    },

    -- ------------------------------------------------------------------------
    -- Appearance
    {
        -- vim.ui.input and vim.ui.select UI delegate.
        "stevearc/dressing.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        event = "VeryLazy",
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        event = "VeryLazy",
    },
    {
        -- Experimental UI for input, select, notification and more.
        "folke/noice.nvim",
        -- enabled = false,
        dependencies = {
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
            "user.config.lsp",
        },
        event = "VeryLazy",
    },
    {
        "startup-nvim/startup.nvim",
        enabled = false,
        dependencies = {
            "user.config.general",
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim"
        },
        event = "VeryLazy",
    },
    {
        -- tab line styling
        "nanozuki/tabby.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Visual Assitance
    {
        -- Indent level visualization.
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        dependencies = {
            "user.config.general",
        },
        event = "BufReadPost",
    },
    {
        -- Highlight line and word under cursor.
        "SirZenith/nvim-cursorline",
        -- dev = true,
        event = "BufReadPost",
    },
    {
        -- Folding support
        "kevinhwang91/nvim-ufo",
        -- enabled = false,
        dependencies = "kevinhwang91/promise-async",
        event = "VeryLazy",
    },
    {
        -- Folding style customization
        "anuvyklack/pretty-fold.nvim",
        enabled = false,
        event = "BufReadPost",
    },
    {
        -- Highlight range argument in command line.
        "winston0410/range-highlight.nvim",
        dependencies = { "winston0410/cmd-parser.nvim" },
        event = "CmdlineEnter",
    },

    -- ------------------------------------------------------------------------
    -- tree-sitter
    {
        "code-biscuits/nvim-biscuits",
        enabled = false,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "VeryLazy",
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "VeryLazy",
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufReadPre",
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = {
            "astro",
            "glimmer",
            "handlebars",
            "html",
            "javascript",
            "jsx",
            "markdown",
            "php",
            "rescript",
            "svelte",
            "tsx",
            "typescript",
            "vue",
            "xml",
        },
    },
    {
        "nvim-treesitter/playground",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufReadPre",
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "user.config.general",
        },
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- LSP
    {
        "SirZenith/lsp-config-loader",
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim",
            "nvim-lua/lsp-status.nvim",
            "neovim/nvim-lspconfig",
        },
        event = "VeryLazy",
    },
    {
        -- LSP status component for Lualine
        "nvim-lua/lsp-status.nvim",
        event = "VeryLazy",
    },
    {
        -- LSP completion item kind icon for completion menu
        "onsails/lspkind.nvim",
        event = "VeryLazy",
    },
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
    },
    {
        -- LSP injection
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
    },
    {
        -- tsserer adapter for NeoVim
        "pmizio/typescript-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            "SirZenith/lsp-config-loader",
        },
        cond = putl.root_file_cond {
            "tsconfig.json",
            "client/tsconfig.json",
        },
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Completion
    {
        "SirZenith/cmd-snippet",
        -- dev = true,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/nvim-cmp",
        },
        event = "InsertEnter",
    },
    {
        "L3MON4D3/LuaSnip",
        event = "VeryLazy",
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "onsails/lspkind.nvim",
            "SirZenith/lsp-config-loader",
        },
        lazy = true,
    },
    {
        "hrsh7th/cmp-buffer",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "BufReadPost",
    },
    {
        "hrsh7th/cmp-cmdline",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = { "CmdlineEnter" },
    },
    {
        "saadparwaiz1/cmp_luasnip",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "InsertEnter",
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "BufReadPost",
    },
    {
        "hrsh7th/cmp-path",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = { "InsertEnter", "CmdlineEnter" },
    },
    {
        "SirZenith/ts-grammar-navigator",
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim",
            "hrsh7th/nvim-cmp",
        },
        ft = "tree-sitter-test",
    },
    {
        "SirZenith/prefab-cmp",
        -- dev = true,
        dependencies = { "hrsh7th/nvim-cmp", },
        event = "InsertEnter",
        cond = putl.root_directory_cond {
            ".creator",
            "client/.creator",
        },
    },
    {
        "SirZenith/snippet-loader",
        -- dev = true,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "SirZenith/cmd-snippet",
        },
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Language Support
    {
        "lervag/vimtex",
        ft = { "tex", "latex", "bibtex" },
    },
    {
        "stevearc/vim-arduino",
        ft = "arduino",
    },
    {
        "sudar/vim-arduino-syntax",
        ft = "arduino",
    },

    -- ------------------------------------------------------------------------
    -- Debugger
    {
        "rcarriga/cmp-dap",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },
    {
        "mfussenegger/nvim-dap",
        cmd = "Dap",
    },
    {
        "LiadOz/nvim-dap-repl-highlights",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },
    {
        -- Display inline variable infomation with virtual text.
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },

    -- ------------------------------------------------------------------------
    -- Version Control System
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
        cond = putl.root_directory_cond { ".git" },
    },
    {
        "SirZenith/vcs-helper.nvim",
        -- dev = true,
        dependencies = { "SirZenith/panelpal.nvim" },
        event = "CmdlineEnter",
        cond = putl.root_directory_cond { ".git", ".svn" },
    },

    -- ------------------------------------------------------------------------
    -- Color
    {
        -- Create Color Code, color picker in NeoVim
        "uga-rosa/ccc.nvim",
        event = "CmdlineEnter",
    },
    {
        -- Highlight color code with its color in vim
        "norcalli/nvim-colorizer.lua",
        event = "BufReadPost",
    },

    -- ------------------------------------------------------------------------
    -- External Tools
    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        ft = { "markdown" },
    },
    {
        "SirZenith/mongosh.nvim",
        -- dev = true,
        dependencies = {
            "nvim-lualine/lualine.nvim",
        },
        cmd = "Mongo",
    },
    {
        -- Preview PlantUML in browser
        "weirongxu/plantuml-previewer.vim",
        dependencies = {
            "aklt/plantuml-syntax",
            "tyru/open-browser.vim",
        },
        ft = "plantuml",
    },
}

return specs
