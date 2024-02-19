local putl = require "user.config.plugins.utils"

local ucs = putl.user_config_spec
local cs = putl.colorscheme_spec

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
    cs { "marko-cerovac/material.nvim", enabled = false },
    cs { "kaicataldo/material.vim", enabled = false },
    cs { "EdenEast/nightfox.nvim" },
    cs { "shaunsingh/nord.nvim", enabled = false },
    cs { "mhartington/oceanic-next", enabled = false },
    cs { "JoosepAlviste/palenightfall.nvim", enabled = false },
    cs { "wadackel/vim-dogrun", enabled = false },
    cs { "rakr/vim-two-firewatch", enabled = false },

    -- ------------------------------------------------------------------------
    -- General
    {
        "numToStr/Comment.nvim",
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
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
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Show bookmark symbols in gutter column.
        "chentoast/marks.nvim",
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Clipboard history manager
        "AckslD/nvim-neoclip.lua",
        requires = {
            -- you'll need at least one of these
            "nvim-telescope/telescope.nvim",
            -- "ibhagwan/fzf-lua",
        },
        keys = "<leader>p"
    },
    {
        "rcarriga/nvim-notify",
        lazy = true,
    },
    {
        "kylechui/nvim-surround",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "nvim-tree/nvim-tree.lua",
        enabled = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
    },
    {
        -- A file explorer that allows you edit your file system as vim buffer.
        "stevearc/oil.nvim",
        event = "VeryLazy",
    },
    {
        -- Display VCS status symbol in oil.nvim buffer's signcolumn
        "SirZenith/oil-vcs-status",
        -- dev = true,
        dependencies = {
            "stevearc/oil.nvim",
        },
        ft = "oil",
        cond = putl.root_directory_cond { ".git", ".svn" },
    },
    {
        "SirZenith/panelpal.nvim",
        -- dev = true,
        lazy = true,
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
        cmd = "Telescope",
        keys = "<leader>f",
    },
    {
        "akinsho/toggleterm.nvim",
        dependencies = { "user.config.general" },
        keys = "<F12>"
    },
    {
        -- Undo tree visualizer.
        "mbbill/undotree",
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
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
        event = { "CmdlineEnter", "InsertEnter", "LspAttach" },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "kyazdani42/nvim-web-devicons",
            "folke/noice.nvim", -- load after noice.nvim
        },
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
        event = "TabNew",
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
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Highlight line and word under cursor.
        "SirZenith/nvim-cursorline",
        -- dev = true,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Folding support
        "kevinhwang91/nvim-ufo",
        -- enabled = false,
        dependencies = "kevinhwang91/promise-async",
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Folding style customization
        "anuvyklack/pretty-fold.nvim",
        enabled = false,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
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
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        ft = "TelescopePrompt",
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
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
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "user.config.general",
        },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
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
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },
    {
        -- LSP status component for Lualine
        "nvim-lua/lsp-status.nvim",
        lazy = true,
    },
    {
        -- LSP completion item kind icon for completion menu
        "onsails/lspkind.nvim",
        lazy = true,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = true,
    },
    {
        -- LSP injection
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
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
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },

    -- ------------------------------------------------------------------------
    -- Completion
    {
        "hrsh7th/cmp-buffer",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = { "InsertEnter", "CmdlineEnter" },
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
        event = "LspAttach",
    },
    {
        "hrsh7th/cmp-path",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = { "InsertEnter", "CmdlineEnter" },
    },
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
        lazy = true,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
    },
    {
        "hrsh7th/nvim-cmp",
        lazy = true,
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
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
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
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
        cond = putl.root_directory_cond { ".git" },
    },
    {
        "SirZenith/vcs-helper.nvim",
        -- dev = true,
        dependencies = { "SirZenith/panelpal.nvim" },
        cmd = {
            "VcsCommit",
            "VcsDiff",
            "VcsStatus",
        },
        cond = putl.root_directory_cond { ".git", ".svn" },
    },

    -- ------------------------------------------------------------------------
    -- Color
    {
        -- Create Color Code, color picker in NeoVim
        "uga-rosa/ccc.nvim",
        cmd = {
            "CccPick",
            "CccConvert",
            "CccHighlighterDisable",
            "CccHighlighterEnable",
            "CccHighlighterToggle",
        },
    },
    {
        -- Highlight color code with its color in vim
        "norcalli/nvim-colorizer.lua",
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
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
