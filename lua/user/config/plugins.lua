local function turn_on_true_color()
    if vim.fn.has "nvim" then
        vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    end

    if vim.fn.has "termguicolors" then
        vim.o.termguicolors = true
    end
end

return {
    "wbthomason/packer.nvim",

    -- ------------------------------------------------------------------------
    -- General
    "lewis6991/gitsigns.nvim",
    "ggandor/leap.nvim", -- search & jump
    "numToStr/Comment.nvim",
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

    "udalov/kotlin-vim",

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
    },
    "lervag/vimtex",
    "stevearc/vim-arduino",
    "sudar/vim-arduino-syntax",
    "vim-voom/VOoM",

    -- ------------------------------------------------------------------------
    -- Completion
    "windwp/nvim-autopairs",
    "windwp/nvim-ts-autotag",
    "L3MON4D3/LuaSnip",
    "hrsh7th/nvim-cmp",
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
    },
    {
        "SirZenith/prefab-cmp",
        requires = {
            "hrsh7th/nvim-cmp",
        },
    },
}
