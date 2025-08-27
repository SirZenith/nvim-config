local putl = require "user.config.plugin.util"

local ucs = putl.user_config_spec
local cs = putl.colorscheme_spec

putl.turn_on_true_color()

---@type (user.plugin.PluginSpec | string)[]
local specs = {
    -- ------------------------------------------------------------------------
    -- User Config
    ucs {
        name = "user-config-lsp",
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        lazy_load = {
            event = {
                {
                    name = "User",
                    load_checker = putl.user_event_cond("UserConfigFinalized"),
                },
                {

                    name = "BufNew",
                    load_checker = putl.new_buffer_trigger_loading_predicate,
                },
            },
        },
    },
    ucs {
        name = "user-config-snippet",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "SirZenith/cmd-snippet",
        },
        lazy_load = {
            event = {
                {
                    name = "User",
                    load_checker = putl.user_event_cond("UserConfigFinalized"),
                },
                {

                    name = "BufNew",
                    load_checker = putl.new_buffer_trigger_loading_predicate,
                },
            },
        },
    },
    ucs {
        name = "update-compiled-config",
        lazy_load = {
            event = {
                {
                    name = "User",
                    load_checker = putl.user_event_cond("UserConfigFinalized"),
                },
            },
        },
    },
    ucs {
        name = "scheme-list-highlight",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        lazy_load = {
            ft = "scheme",
        },
    },

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
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- Jump to anywhere with a few key strokes
        "ggandor/leap.nvim",
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- Show bookmark symbols in gutter column.
        "chentoast/marks.nvim",
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        "rcarriga/nvim-notify",
        lazy_load = {
            lazy = true,
        },
    },
    {
        "kylechui/nvim-surround",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects"
        },
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- A file explorer that allows you edit your file system as vim buffer.
        "stevearc/oil.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        lazy_load = {
            very_lazy = true,
        },
    },
    {
        -- Display VCS status symbol in oil.nvim buffer's signcolumn
        "SirZenith/oil-vcs-status",
        -- dev = true,
        dependencies = {
            "stevearc/oil.nvim",
        },
        lazy_load = {
            ft = "oil",
            cond = putl.fs_entry_cond { ".git", ".svn" },
        },
    },
    {
        "SirZenith/panelpal.nvim",
        -- dev = true,
        lazy_load = {
            lazy = true,
        },
    },
    {
        -- Global Search & Replace
        "nvim-pack/nvim-spectre",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        lazy_load = {
            cmd = {
                "SearchAndReplace",
                "Spectre",
            },
        }
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim"
        },
        lazy_load = {
            cmd = "Telescope",
            keys = "<leader>f",
        },
    },
    {
        "akinsho/toggleterm.nvim",
        lazy_load = {
            keys = "<F12>"
        },
    },
    {
        -- Undo tree visualizer.
        "mbbill/undotree",
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- Symbol tree view for code and markup
        "simrat39/symbols-outline.nvim",
        lazy_load = {
            cmd = {
                "SymbolsOutline",
                "SymbolsOutlineOpen",
                "SymbolsOutlineClose",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- Appearance
    {
        -- vim.ui.input and vim.ui.select UI delegate.
        "stevearc/dressing.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        lazy_load = {
            event = { "CmdlineEnter", "InsertEnter", "LspAttach" },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "folke/noice.nvim", -- load after noice.nvim
        },
        lazy_load = {
            very_lazy = true,
        },
    },
    {
        -- Experimental UI for input, select, notification and more.
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        lazy_load = {
            very_lazy = true,
        },
    },
    {
        -- tab line styling
        "nanozuki/tabby.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        lazy_load = {
            event = {
                "TabNew",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- Visual Assitance
    {
        -- Indent level visualization.
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- Highlight line and word under cursor.
        "SirZenith/nvim-cursorline",
        -- dev = true,
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- Folding support
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async"
        },
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        -- Folding style customization
        "anuvyklack/pretty-fold.nvim",
        enabled = false,
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- tree-sitter
    {
        "nvim-treesitter/nvim-treesitter",
        -- build = ":TSUpdate",
        -- branch = "main",
        lazy_load = {
            ft = "TelescopePrompt",
            event = {
                {
                    name = "User",
                    load_checker = putl.user_event_cond("UserConfigFinalized"),
                },
                {

                    name = { "BufNew", "CmdlineEnter" },
                    load_checker = putl.new_buffer_trigger_loading_predicate,
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        lazy_load = {
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
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        lazy_load = {
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
                {
                    name = "User",
                    load_checker = putl.user_event_cond("UserConfigFinalized"),
                },
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- LSP
    {
        -- LSP completion item kind icon for completion menu
        "onsails/lspkind.nvim",
        lazy_load = {
            lazy = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy_load = {
            lazy = true,
        },
    },

    -- ------------------------------------------------------------------------
    -- Completion
    {
        "hrsh7th/cmp-buffer",
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        lazy_load = {
            event = { "InsertEnter", "CmdlineEnter" },
        },
    },
    {
        "hrsh7th/cmp-cmdline",
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        lazy_load = {
            event = { "CmdlineEnter" },
        },
    },
    {
        "saadparwaiz1/cmp_luasnip",
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        lazy_load = {
            event = {
                "InsertEnter"
            },
        },
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        lazy_load = {
            event = { "LspAttach" },
        },
    },
    {
        "hrsh7th/cmp-path",
        dependencies = {
            "hrsh7th/nvim-cmp"
        },
        lazy_load = {
            event = { "InsertEnter", "CmdlineEnter" },
        },
    },
    {
        "SirZenith/cmd-snippet",
        -- dev = true,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/nvim-cmp",
        },
        lazy_load = {
            event = { "InsertEnter" },
        },
    },
    {
        "L3MON4D3/LuaSnip",
        lazy_load = {
            lazy = true,
        },
    },
    {
        "windwp/nvim-autopairs",
        lazy_load = {
            event = { "InsertEnter" },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        lazy_load = {
            lazy = true,
        },
    },
    {
        "SirZenith/ts-grammar-navigator",
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim",
            "hrsh7th/nvim-cmp",
        },
        lazy_load = {
            ft = "tree-sitter-test",
        },
    },
    {
        "SirZenith/prefab-cmp",
        -- dev = true,
        dependencies = {
            "hrsh7th/nvim-cmp",
        },
        lazy_load = {
            event = { "InsertEnter" },
            cond = putl.root_directory_cond {
                ".creator",
                "client/.creator",
            },
        }
    },

    -- ------------------------------------------------------------------------
    -- Language Support
    {
        -- Formatter integration
        "stevearc/conform.nvim",
        lazy_load = {
            event = {
                {
                    name = "User",
                    load_checker = putl.user_event_cond("UserConfigFinalized"),
                },
                {
                    name = "BufNew",
                    load_checker = putl.new_buffer_trigger_loading_predicate,
                },
            },
            ft = "TelescopePrompt",
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        lazy_load = {
            ft = "markdown",
        }
    },
    {
        "lervag/vimtex",
        lazy_load = {
            ft = { "tex", "latex", "bibtex" },
        },
    },
    {
        "stevearc/vim-arduino",
        lazy_load = {
            ft = "arduino",
        },
    },
    {
        "sudar/vim-arduino-syntax",
        lazy_load = {
            ft = "arduino",
        },
    },

    -- ------------------------------------------------------------------------
    -- Debugger
    {
        "rcarriga/cmp-dap",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        lazy_load = {
            cmd = "Dap",
        },
    },
    {
        "mfussenegger/nvim-dap",
        lazy_load = {
            cmd = "Dap",
        },
    },
    {
        "LiadOz/nvim-dap-repl-highlights",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        lazy_load = {
            cmd = "Dap",
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        lazy_load = {
            cmd = "Dap",
        },
    },
    {
        -- Display inline variable infomation with virtual text.
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "mfussenegger/nvim-dap",
        },
        lazy_load = {
            cmd = "Dap",
        },
    },

    -- ------------------------------------------------------------------------
    -- Version Control System
    {
        "lewis6991/gitsigns.nvim",
        lazy_load = {
            cond = putl.root_directory_cond { ".git" },
            event = {
                {
                    name = "BufEnter",
                    load_checker = putl.buffer_enter_trigger_loading_predicate,
                },
            },
        },
    },
    {
        "SirZenith/vcs-helper.nvim",
        -- dev = true,
        dependencies = {
            "SirZenith/panelpal.nvim"
        },
        lazy_load = {
            cond = putl.fs_entry_cond { ".git", ".svn" },
            cmd = {
                "VcsCommit",
                "VcsDiff",
                "VcsStatus",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- Color
    {
        -- Create Color Code, color picker in NeoVim
        "uga-rosa/ccc.nvim",
        lazy_load = {
            cmd = {
                "CccPick",
                "CccConvert",
                "CccHighlighterDisable",
                "CccHighlighterEnable",
                "CccHighlighterToggle",
            },
        },
    },

    -- ------------------------------------------------------------------------
    -- External Tools
    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        lazy_load = {
            ft = { "markdown" },
        },
    },
    {
        "SirZenith/mongosh.nvim",
        -- dev = true,
        dependencies = {
            "nvim-lualine/lualine.nvim",
        },
        lazy_load = {
            cmd = "Mongo",
        },
    },
}

return specs
