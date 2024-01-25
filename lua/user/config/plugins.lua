local base_config, err = require "user.config"
if err then
    return {}
end

local function turn_on_true_color()
    if vim.fn.has "nvim" then
        vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    end

    if vim.fn.has "termguicolors" then
        vim.o.termguicolors = true
    end
end

-- Looing for a directory recrusively in parent
---@param target_names string[] # target directory name
---@return boolean is_found
local function find_root_by_directory(target_names)
    local pwd = vim.fn.getcwd()

    local is_found = false
    for _, target_name in ipairs(target_names) do
        if vim.fn.isdirectory(pwd .. "/" .. target_name) == 1 then
            is_found = true
            break
        end

        for dir in vim.fs.parents(pwd) do
            if vim.fn.isdirectory(dir .. "/" .. target_name) == 1 then
                is_found = true
                break
            end
        end
    end

    return is_found
end

-- Looing for a file recrusively in parent
---@param target_names string[] # target file name
---@return boolean is_found
local function find_root_by_file(target_names)
    local pwd = vim.fn.getcwd()

    local is_found = false
    for _, target_name in ipairs(target_names) do
        if vim.fn.filereadable(pwd .. "/" .. target_name) == 1 then
            is_found = true
            break
        end

        for dir in vim.fs.parents(pwd) do
            if vim.fn.filereadable(dir .. "/" .. target_name) == 1 then
                is_found = true
                break
            end
        end
    end

    return is_found
end

---@type (PluginSpec | string)[]
local specs = {
    -- ------------------------------------------------------------------------
    -- Local configs
    {
        name = "user.config.general",
        dir = base_config.env.USER_RUNTIME_PATH,
        config = function(spec) require(spec.name) end,
    },
    {
        name = "user.config.keybinding",
        dir = base_config.env.USER_RUNTIME_PATH,
        dependencies = {
            "SirZenith/panelpal.nvim",
            "user.config.general",
        },
        config = function(spec) require(spec.name) end,
    },
    {
        name = "user.config.command",
        dir = base_config.env.USER_RUNTIME_PATH,
        config = function(spec) require(spec.name) end,
    },
    {
        name = "user.config.platforms",
        dir = base_config.env.USER_RUNTIME_PATH,
        dependencies = {
            "user.config.general",
        },
        config = function(spec) require(spec.name) end,
    },
    {
        name = "user.config.lsp",
        dir = base_config.env.USER_RUNTIME_PATH,
        config = function(spec) require(spec.name) end,
    },
    {
        name = "user.workspace",
        dir = base_config.env.USER_RUNTIME_PATH,
        config = function(spec) require(spec.name) end,
    },

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
        "stevearc/dressing.nvim",
        -- enabled = false,
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        event = "VeryLazy",
    },
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPost",
        cond = function()
            return find_root_by_directory { ".git" }
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
        event = "BufReadPost",
    },
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
            "user.config.lsp",
        },
        event = "CmdlineEnter",
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
    },
    {
        "startup-nvim/startup.nvim",
        dependencies = {
            "user.config.general",
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim"
        },
        event = "VeryLazy",
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
    },
    {
        "SirZenith/vcs-helper.nvim",
        -- dev = true,
        dependencies = { "SirZenith/panelpal.nvim" },
        event = "CmdlineEnter",
        cond = function()
            return find_root_by_directory { ".git", ".svn" }
        end,
    },
    {
        "voldikss/vim-floaterm",
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- Visual Assitance
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        dependencies = {
            "user.config.general",
        },
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
        event = "BufReadPost",
    },
    {
        -- folding style customization
        "anuvyklack/pretty-fold.nvim",
        event = "BufReadPost",
    },
    {
        -- tab line styling
        "nanozuki/tabby.nvim",
        event = "VeryLazy",
    },

    -- ------------------------------------------------------------------------
    -- tree-sitter
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "user.config.general",
        },
        build = ":TSUpdate",
        event = "VeryLazy",
    },
    {
        "nvim-treesitter/playground",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "BufReadPre",
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
        "hiphish/rainbow-delimiters.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
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
        "pmizio/typescript-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            "SirZenith/lsp-config-loader",
        },
        cond = function()
            return find_root_by_file {
                "tsconfig.json",
                "client/tsconfig.json",
            }
        end,
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
        cond = function()
            return find_root_by_directory {
                ".creator",
                "client/.creator",
            }
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
    {
        "vim-voom/VOoM",
        ft = { "markdown", "html" },
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
