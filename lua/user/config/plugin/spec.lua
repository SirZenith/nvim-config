local putl = require "user.config.plugin.util"
local workspace = require "user.config.workspace"

local ucs = putl.user_config_spec
local cs = putl.colorscheme_spec

putl.turn_on_true_color()

---@type (user.plugin.PluginSpec | string)[]
local specs = {
    -- ------------------------------------------------------------------------
    -- Local configs
    ucs {
        name = "user.config.general",
        no_auto_dependencies = true,
    },
    ucs "user.config.filetype",
    ucs "user.config.keybinding",
    ucs "user.config.command",
    ucs "user.config.platform",
    ucs "user.config.lsp",
    ucs "user.config.workspace",
    ucs "user.config.autocmd",

    -- ------------------------------------------------------------------------
    -- Themes
    cs { "EdenEast/nightfox.nvim" },
    cs { "mhartington/oceanic-next", enabled = false },
    cs { "JoosepAlviste/palenightfall.nvim", enabled = false },
    cs { "wadackel/vim-dogrun", enabled = false },
    cs { "rakr/vim-two-firewatch", enabled = false },

    -- ------------------------------------------------------------------------
    -- General
    {
        "numToStr/Comment.nvim",
        -- enabled = false,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Collaborative edit support
        "jbyuki/instant.nvim",
        -- enabled = false,
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
        -- enabled = false,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Clipboard history manager
        "AckslD/nvim-neoclip.lua",
        -- enabled = false,
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
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects"
        },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "nvim-tree/nvim-tree.lua",
        enabled = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        event = "VeryLazy",
    },
    {
        -- A file explorer that allows you edit your file system as vim buffer.
        "stevearc/oil.nvim",
        -- enabled = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        event = "VeryLazy",
    },
    {
        -- Display VCS status symbol in oil.nvim buffer's signcolumn
        "SirZenith/oil-vcs-status",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "stevearc/oil.nvim",
        },
        ft = "oil",
        cond = putl.fs_entry_cond { ".git", ".svn" },
    },
    {
        "SirZenith/panelpal.nvim",
        -- enabled = false,
        -- dev = true,
        lazy = true,
    },
    {
        -- Global Search & Replace
        "nvim-pack/nvim-spectre",
        -- enabled = false,
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
        -- enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim"
        },
        cmd = "Telescope",
        keys = "<leader>f",
    },
    {
        "akinsho/toggleterm.nvim",
        -- enabled = false,
        dependencies = {
            ucs "user.config.general",
        },
        keys = "<F12>"
    },
    {
        -- Undo tree visualizer.
        "mbbill/undotree",
        -- enabled = false,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "ThePrimeagen/vim-be-good",
        -- enabled = false,
        cmd = "VimBeGood",
    },
    {
        -- Symbol tree view for code and markup
        "simrat39/symbols-outline.nvim",
        -- enabled = false,
        cmd = {
            "SymbolsOutline",
            "SymbolsOutlineOpen",
            "SymbolsOutlineClose",
        },
    },

    -- ------------------------------------------------------------------------
    -- Appearance
    {
        -- vim.ui.input and vim.ui.select UI delegate.
        "stevearc/dressing.nvim",
        -- enabled = false,
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        event = { "CmdlineEnter", "InsertEnter", "LspAttach" },
    },
    {
        "nvim-lualine/lualine.nvim",
        -- enabled = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
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
            ucs "user.config.lsp",
        },
        event = "VeryLazy",
    },
    {
        -- tab line styling
        "nanozuki/tabby.nvim",
        -- enabled = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        event = "TabNew",
    },

    -- ------------------------------------------------------------------------
    -- Visual Assitance
    {
        -- Indent level visualization.
        "lukas-reineke/indent-blankline.nvim",
        -- enabled = false,
        main = "ibl",
        dependencies = {
            ucs "user.config.general",
        },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Highlight line and word under cursor.
        "SirZenith/nvim-cursorline",
        -- enabled = false,
        -- dev = true,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        -- Folding support
        "kevinhwang91/nvim-ufo",
        -- enabled = false,
        dependencies = {
            "kevinhwang91/promise-async"
        },
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

    -- ------------------------------------------------------------------------
    -- tree-sitter
    {
        "nvim-treesitter/nvim-treesitter",
        -- enabled = false,
        -- build = ":TSUpdate",
        ft = "TelescopePrompt",
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "windwp/nvim-ts-autotag",
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
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
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            ucs "user.config.general",
        },
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },

    -- ------------------------------------------------------------------------
    -- LSP
    {
        "SirZenith/lsp-config-loader",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim",
            "nvim-lua/lsp-status.nvim",
            "neovim/nvim-lspconfig",
        },
        ft = "TelescopePrompt",
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },
    {
        -- LSP status component for Lualine
        "nvim-lua/lsp-status.nvim",
        -- enabled = false,
        lazy = true,
    },
    {
        -- LSP completion item kind icon for completion menu
        "onsails/lspkind.nvim",
        -- enabled = false,
        lazy = true,
    },
    {
        "neovim/nvim-lspconfig",
        -- enabled = false,
        lazy = true,
    },
    {
        -- tsserer adapter for NeoVim
        "pmizio/typescript-tools.nvim",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            "SirZenith/lsp-config-loader",
        },
        cond = putl.root_file_cond {
            "tsconfig.json",
            "client/tsconfig.json",
            "project.code-workspace",
        },
        ft = "TelescopePrompt",
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },

    -- ------------------------------------------------------------------------
    -- Completion
    {
        "hrsh7th/cmp-buffer",
        -- enabled = false,
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        event = { "InsertEnter", "CmdlineEnter" },
    },
    {
        "hrsh7th/cmp-cmdline",
        -- enabled = false,
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        event = { "CmdlineEnter" },
    },
    {
        "saadparwaiz1/cmp_luasnip",
        -- enabled = false,
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        event = "InsertEnter",
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        -- enabled = false,
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        event = "LspAttach",
    },
    {
        "hrsh7th/cmp-path",
        -- enabled = false,
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        event = { "InsertEnter", "CmdlineEnter" },
    },
    {
        "SirZenith/cmd-snippet",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/nvim-cmp",
        },
        event = "InsertEnter",
    },
    {
        "L3MON4D3/LuaSnip",
        -- enabled = false,
        lazy = true,
    },
    {
        "windwp/nvim-autopairs",
        -- enabled = false,
        event = "InsertEnter",
    },
    {
        "hrsh7th/nvim-cmp",
        -- enabled = false,
        lazy = true,
    },
    {
        "SirZenith/ts-grammar-navigator",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim",
            "hrsh7th/nvim-cmp",
        },
        ft = "tree-sitter-test",
    },
    {
        "SirZenith/prefab-cmp",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "hrsh7th/nvim-cmp",
        },
        event = "InsertEnter",
        cond = function()
            return putl.root_directory_cond {
                ".creator",
                "client/.creator",
            }
        end,
    },
    {
        "SirZenith/snippet-loader",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "SirZenith/cmd-snippet",
        },
        ft = "TelescopePrompt",
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },

    -- ------------------------------------------------------------------------
    -- Language Support
    {
        -- Formatter integration
        "stevearc/conform.nvim",
        -- enabled = false,
        ft = "TelescopePrompt",
        event = "BufNew",
        autocmd_load_checker = putl.new_buffer_trigger_loading_predicate,
    },
    {
        "lervag/vimtex",
        -- enabled = false,
        ft = { "tex", "latex", "bibtex" },
    },
    {
        "stevearc/vim-arduino",
        -- enabled = false,
        ft = "arduino",
    },
    {
        "sudar/vim-arduino-syntax",
        -- enabled = false,
        ft = "arduino",
    },

    -- ------------------------------------------------------------------------
    -- Debugger
    {
        "rcarriga/cmp-dap",
        -- enabled = false,
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },
    {
        "mfussenegger/nvim-dap",
        -- enabled = false,
        cmd = "Dap",
    },
    {
        "LiadOz/nvim-dap-repl-highlights",
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },
    {
        "rcarriga/nvim-dap-ui",
        -- enabled = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        cmd = "Dap",
    },
    {
        -- Display inline variable infomation with virtual text.
        "theHamsta/nvim-dap-virtual-text",
        -- enabled = false,
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
        -- enabled = false,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
        cond = putl.root_directory_cond { ".git" },
    },
    {
        "SirZenith/vcs-helper.nvim",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim"
        },
        cmd = {
            "VcsCommit",
            "VcsDiff",
            "VcsStatus",
        },
        cond = putl.fs_entry_cond { ".git", ".svn" },
    },

    -- ------------------------------------------------------------------------
    -- Color
    {
        -- Create Color Code, color picker in NeoVim
        "uga-rosa/ccc.nvim",
        -- enabled = false,
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
        -- enabled = false,
        event = "BufEnter",
        autocmd_load_checker = putl.buffer_enter_trigger_loading_predicate,
    },

    -- ------------------------------------------------------------------------
    -- External Tools
    {
        "iamcco/markdown-preview.nvim",
        -- enabled = false,
        build = function() vim.fn["mkdp#util#install"]() end,
        ft = { "markdown" },
    },
    {
        "SirZenith/mongosh.nvim",
        -- enabled = false,
        -- dev = true,
        dependencies = {
            "nvim-lualine/lualine.nvim",
        },
        cmd = "Mongo",
    },
    {
        -- Preview PlantUML in browser
        -- enabled = false,
        "weirongxu/plantuml-previewer.vim",
        dependencies = {
            "aklt/plantuml-syntax",
            "tyru/open-browser.vim",
        },
        ft = "plantuml",
    },
}

return specs
