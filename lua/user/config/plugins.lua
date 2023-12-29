local base_config, err = require "user.config"
if err then
    return {}
end

local fs = require "user.utils.fs"

local function turn_on_true_color()
    if vim.fn.has "nvim" then
        vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    end

    if vim.fn.has "termguicolors" then
        vim.o.termguicolors = true
    end
end

-- Looing for a directory recrusively in parent
---@param target_name string # target directory name
---@return boolean is_found
local function find_root_by_directory(target_name)
    local pwd = vim.fn.getcwd()

    if vim.fn.isdirectory(pwd .. "/" .. target_name) == 1 then
        return true;
    end

    for dir in vim.fs.parents(pwd) do
        if vim.fn.isdirectory(dir .. "/" .. target_name) == 1 then
            return true;
        end
    end

    return false
end

-- Looing for a file recrusively in parent
---@param target_name string # target file name
---@return boolean is_found
local function find_root_by_file(target_name)
    local pwd = vim.fn.getcwd()

    if vim.fn.filereadable(pwd .. "/" .. target_name) == 1 then
        return true;
    end

    for dir in vim.fs.parents(pwd) do
        if vim.fn.filereadable(dir .. "/" .. target_name) == 1 then
            return true;
        end
    end

    return false
end

---@type (PluginSpec | string)[]
local specs = {
    -- ------------------------------------------------------------------------
    -- General
    {
        "lewis6991/gitsigns.nvim",
        cond = function()
            return find_root_by_directory('.git')
        end,
    },
    -- "ggandor/leap.nvim", -- search & jump
    "numToStr/Comment.nvim",
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    "SirZenith/panelpal.nvim",
    {
        "SirZenith/vcs-helper.nvim",
        dependencies = { "SirZenith/panelpal.nvim" },
        cond = function()
            return find_root_by_directory('.git') or find_root_by_directory('.svn')
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
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
        before_load = turn_on_true_color
    },
    "anuvyklack/pretty-fold.nvim", -- folding style customization

    -- ------------------------------------------------------------------------
    -- Themes
    {
        "catppuccin/nvim",
        name = "catppuccin",
        enabled = false,
    },
    { "marko-cerovac/material.nvim", enabled = false },
    { "kaicataldo/material.vim",     enabled = false },
    {
        "EdenEast/nightfox.nvim",
        before_load = turn_on_true_color,
        priority = 60,
    },
    { "shaunsingh/nord.nvim",             enabled = false },
    { "mhartington/oceanic-next",         enabled = false },
    { "JoosepAlviste/palenightfall.nvim", enabled = false },
    { "wadackel/vim-dogrun",              enabled = false },
    { "rakr/vim-two-firewatch",           enabled = false },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
    },
    "nanozuki/tabby.nvim", -- tab line styling

    -- ------------------------------------------------------------------------
    -- Syntax
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },
    {
        "nvim-treesitter/playground",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "p00f/nvim-ts-rainbow",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },

    -- ------------------------------------------------------------------------
    -- Language Support
    {
        -- folding support
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        enabled = false,
    },
    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        ft = { "markdown" }
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "local::language-server" }
    },
    {
        -- LSP injection
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
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
    {
        "pmizio/typescript-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            "local::language-server",
        },
        cond = function()
            return find_root_by_file('tsconfig.json')
        end,
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
        ft = { "markdown", "html" },
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
        dependencies = {
            "L3MON4D3/LuaSnip",
            "onsails/lspkind.nvim",
            "local::language-server",
            "local::snippets",
        },
    },
    {
        "hrsh7th/cmp-buffer",
        dependencies = { "hrsh7th/nvim-cmp" },
    },
    {
        "hrsh7th/cmp-cmdline",
        dependencies = { "hrsh7th/nvim-cmp" },
    },
    {
        "saadparwaiz1/cmp_luasnip",
        dependencies = { "hrsh7th/nvim-cmp" },
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = { "hrsh7th/nvim-cmp" },
    },
    {
        "hrsh7th/cmp-path",
        dependencies = { "hrsh7th/nvim-cmp" },
    },
    {
        "SirZenith/ts-grammar-navigator",
        dependencies = {
            "SirZenith/panelpal.nvim",
            "hrsh7th/nvim-cmp",
        },
        ft = "tree-sitter-test",
    },
    {
        "SirZenith/prefab-cmp",
        dependencies = { "hrsh7th/nvim-cmp", },
        cond = function()
            return find_root_by_directory('.creator')
        end,
    },

    -- ------------------------------------------------------------------------
    -- Local plugins
    {
        name = "local::general",
        dir = fs.path_join(base_config.env.CONFIG_HOME, "user", "config", "general"),
        config = function() require "user.config.general" end,
    },
    {
        name = "local::keybinding",
        dir = fs.path_join(base_config.env.CONFIG_HOME, "user", "config", "keybinding"),
        dependencies = {
            "SirZenith/panelpal.nvim",
            "local::general",
        },
        config = function() require "user.config.keybinding" end,
    },
    {
        name = "local::language-server",
        dir = fs.path_join(base_config.env.CONFIG_HOME, "user", "config", "language-server"),
        dependencies = {
            "SirZenith/panelpal.nvim"
        },
        config = function() require "user.config.language-server" end,
    },
    {
        name = "local::snippets",
        dir = fs.path_join(base_config.env.SNIPPET_ROOT),
        dependencies = { "L3MON4D3/LuaSnip" },
        config = function() require "user.config.snippets" end,
    },
    {
        name = "local::command",
        dir = fs.path_join(base_config.env.CONFIG_HOME, "user", "config", "command"),
        dependencies = {
            "local::language-server",
            "local::snippets"
        },
        config = function() require "user.config.command" end,
    },
    {
        name = "local::platforms",
        dir = fs.path_join(base_config.env.CONFIG_HOME, "user", "config", "platforms"),
        dependencies = {
            "local::general",
        },
        config = function() require "user.config.platforms" end,
    },
    {
        name = "local::workspace",
        dir = fs.path_join(base_config.env.CONFIG_HOME, "user", "workspace"),
        config = function() require "user.workspace" end,
    },
}

return specs
