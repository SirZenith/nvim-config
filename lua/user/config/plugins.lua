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
    },
    { "shaunsingh/nord.nvim",             enabled = false },
    { "mhartington/oceanic-next",         enabled = false },
    { "JoosepAlviste/palenightfall.nvim", enabled = false },
    { "wadackel/vim-dogrun",              enabled = false },
    { "rakr/vim-two-firewatch",           enabled = false },


    -- ------------------------------------------------------------------------
    -- General
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
        cond = function()
            return find_root_by_directory('.git')
        end,
    },
    {
        -- search & jump
        "ggandor/leap.nvim",
        enabled = false,
        event = "BufReadPost",
    },
    {
        "numToStr/Comment.nvim",
        event = "BufReadPre",
    },
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        event = "VeryLazy",
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    "SirZenith/panelpal.nvim",
    {
        "SirZenith/vcs-helper.nvim",
        dependencies = { "SirZenith/panelpal.nvim" },
        event = "VeryLazy",
        cond = function()
            return find_root_by_directory('.git') or find_root_by_directory('.svn')
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
    },
    {
        "voldikss/vim-floaterm",
        keys = "<F12>",
    },

    -- ------------------------------------------------------------------------
    -- Visual Assitance
    {
        "Yggdroot/indentline",
        event = "BufReadPost",
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        event = "VeryLazy",
    },
    {
        "SirZenith/nvim-cursorline",
        event = "BufReadPost",
    },
    {
        -- highlight color code with its color in vim
        "norcalli/nvim-colorizer.lua",
        before_load = turn_on_true_color,
        event = "BufReadPost",
    },
    {
        -- folding support
        "kevinhwang91/nvim-ufo",
        enabled = false,
        dependencies = "kevinhwang91/promise-async",
        event = "BufReadPre",
    },
    {
        -- folding style customization
        "anuvyklack/pretty-fold.nvim",
        event = "BufReadPre",
    },
    {
        -- tab line styling
        "nanozuki/tabby.nvim",
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Syntax
    {
        "nvim-treesitter/nvim-treesitter",
        build = "<cmd>TSUpdate<cr>",
        event = "VeryLazy",
    },
    {
        "nvim-treesitter/playground",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufReadPre",
    },
    {
        "p00f/nvim-ts-rainbow",
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

    -- ------------------------------------------------------------------------
    -- Language Support
    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        ft = { "markdown" },
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
    -- LSP
    {
        "nvim-lua/lsp-status.nvim",
        event = "VeryLazy",
    },
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
    },
    {
        -- LSP completion item kind icon for completion menu
        "onsails/lspkind.nvim",
        event = "BufReadPost",
    },
    {
        -- LSP injection
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufReadPre",
    },
    {
        "pmizio/typescript-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            "SirZenith/lsp-config-loader",
        },
        cond = function()
            return find_root_by_file('tsconfig.json')
        end,
        event = "VeryLazy",
    },

    {
        "SirZenith/lsp-config-loader",
        dependencies = {
            "SirZenith/panelpal.nvim",
            "nvim-lua/lsp-status.nvim",
            "neovim/nvim-lspconfig",
        },
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Completion
    {
        "SirZenith/cmd-snippet",
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
        keys = ":",
    },
    {
        "saadparwaiz1/cmp_luasnip",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "InsertEnter",
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "InsertEnter",
    },
    {
        "hrsh7th/cmp-path",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "InsertEnter",
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
        event = "InsertEnter",
        cond = function()
            return find_root_by_directory('.creator')
        end,
    },
    {
        "SirZenith/snippet-loader",
        dependencies = {
            "L3MON4D3/LuaSnip",
            "SirZenith/cmd-snippet",
        },
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Local configs
    {
        name = "local.general",
        dir = fs.path_join(base_config.env.USER_RUNTIME_PATH, "user", "config", "general"),
        config = function() require "user.config.general" end,
    },
    {
        name = "local.keybinding",
        dir = fs.path_join(base_config.env.USER_RUNTIME_PATH, "user", "config", "keybinding"),
        dependencies = {
            "SirZenith/panelpal.nvim",
            "local.general",
        },
        config = function() require "user.config.keybinding" end,
    },
    {
        name = "local.command",
        dir = fs.path_join(base_config.env.USER_RUNTIME_PATH, "user", "config", "command"),
        config = function() require "user.config.command" end,
    },
    {
        name = "local.platforms",
        dir = fs.path_join(base_config.env.USER_RUNTIME_PATH, "user", "config", "platforms"),
        dependencies = {
            "local.general",
        },
        config = function() require "user.config.platforms" end,
    },
    {
        name = "local.workspace",
        dir = fs.path_join(base_config.env.USER_RUNTIME_PATH, "user", "workspace"),
        config = function() require "user.workspace" end,
    },
}

return specs
