local function turn_on_true_color()
    if vim.fn.has "nvim" then
        vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    end

    if vim.fn.has "termguicolors" then
        vim.o.termguicolors = true
    end
end

---@type (packer.PluginSpec | string)[]
local specs = {
    "wbthomason/packer.nvim",

    -- ------------------------------------------------------------------------
    -- General
    "lewis6991/gitsigns.nvim",
    "ggandor/leap.nvim", -- search & jump
    "numToStr/Comment.nvim",
    --[[ {
        "VonHeikemen/fine-cmdline.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            "hrsh7th/nvim-cmp",
        }
    }, ]]
    {
        "folke/noice.nvim",
        requires = {
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    },
    {
        "nvim-tree/nvim-tree.lua",
        requires = { "nvim-tree/nvim-web-devicons" },
    },
    "SirZenith/panelpal.nvim",
    {
        "SirZenith/vcs-helper.nvim",
        requires = { "SirZenith/panelpal.nvim" },
    },
    {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    },
    "voldikss/vim-floaterm",

    -- ------------------------------------------------------------------------
    -- Visual Assitance
    "Yggdroot/indentline",
    "nvim-lua/lsp-status.nvim",
    "SirZenith/nvim-cursorline",
    {
        -- highlight color code with its color in vim
        "norcalli/nvim-colorizer.lua",
        __before_load = turn_on_true_color
    },
    { "anuvyklack/pretty-fold.nvim", disable = true },

    -- ------------------------------------------------------------------------
    -- Themes
    {
        "catppuccin/nvim",
        as = "catppuccin",
        disable = true
    },
    { "marko-cerovac/material.nvim", disable = true },
    { "kaicataldo/material.vim",     disable = true },
    {
        "EdenEast/nightfox.nvim",
        __before_load = turn_on_true_color,
    },
    { "shaunsingh/nord.nvim",             disable = true },
    { "mhartington/oceanic-next",         disable = true },
    { "JoosepAlviste/palenightfall.nvim", disable = true },
    { "wadackel/vim-dogrun",              disable = true },
    { "rakr/vim-two-firewatch",           disable = true },
    {
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
    },
    "nanozuki/tabby.nvim", -- tab line styling

    -- ------------------------------------------------------------------------
    -- Syntax
    "nvim-treesitter/nvim-treesitter",
    {
        "nvim-treesitter/playground",
        requires = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "p00f/nvim-ts-rainbow",
        requires = { "nvim-treesitter/nvim-treesitter" },
    },

    -- ------------------------------------------------------------------------
    -- Language Support
    {
        -- folding support
        "kevinhwang91/nvim-ufo",
        requires = "kevinhwang91/promise-async"
    },
    {
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    },
    "neovim/nvim-lspconfig",
    {
        -- LSP injection
        "jose-elias-alvarez/null-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    },
    {
        -- Preview PlantUML in browser
        "weirongxu/plantuml-previewer.vim",
        requires = {
            "aklt/plantuml-syntax",
            "tyru/open-browser.vim",
        },
        ft = "plantuml",
    },
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
    {
        "vim-voom/VOoM",
        ft = "markdown",
    },

    -- ------------------------------------------------------------------------
    -- Completion
    "L3MON4D3/LuaSnip",
    "onsails/lspkind.nvim", -- LSP completion item kind icon for completion menu
    "windwp/nvim-autopairs",
    {
        "windwp/nvim-ts-autotag",
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
        "hrsh7th/nvim-cmp",
        requires = {
            "L3MON4D3/LuaSnip",
            "onsails/lspkind.nvim",
        },
    },
    {
        "hrsh7th/cmp-buffer",
        requires = { "hrsh7th/nvim-cmp" },
    },
    {
        "hrsh7th/cmp-cmdline",
        requires = { "hrsh7th/nvim-cmp" },
    },
    {
        "saadparwaiz1/cmp_luasnip",
        requires = { "hrsh7th/nvim-cmp" },
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        requires = { "hrsh7th/nvim-cmp" },
    },
    {
        "hrsh7th/cmp-path",
        requires = { "hrsh7th/nvim-cmp" },
    },
    {
        "SirZenith/ts-grammar-navigator",
        requires = {
            "SirZenith/panelpal.nvim",
            "hrsh7th/nvim-cmp",
        },
        ft = "tree-sitter-test",
    },
    {
        "SirZenith/prefab-cmp",
        requires = {
            "hrsh7th/nvim-cmp",
        },
    },
}

return specs
