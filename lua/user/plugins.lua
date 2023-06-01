local user = require "user"
local utils = require "user.utils"
local import = utils.import
local fs = require "user.utils.fs"

if vim.fn.executable("git") == 0 then
    error("can't find command git.")
end

local fn = vim.fn

local M = {}

LUA_LINE_THEME = nil ---@type string?

local loaded_plugin_list = {}
local modules = {}

local function get_config_name(path)
    return fs.path_join("plugins", path, "config.lua")
end

local function require_packer()
    local is_bootstranp = false
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

    if fn.empty(fn.glob(install_path)) == 1 then
        is_bootstranp = true

        fn.system {
            "git",
            "clone",
            "--depth",
            "1",
            "https://github.com/wbthomason/packer.nvim",
            install_path,
        }
    end

    vim.cmd "packadd packer.nvim"

    return is_bootstranp, require("packer")
end

local function load_config(spec)
    local path
    local spec_type = type(spec)
    if spec_type == "table" then
        path = not spec.disable and spec[1] or nil
    elseif spec_type == "string" then
        path = spec
    end

    if not path or #path == 0 then return end

    local cfg_name = get_config_name(path)
    local file = fs.path_join(user.env.CONFIG_HOME(), cfg_name)
    if fn.filereadable(file) ~= 0 then
        local module = import(cfg_name)
        modules[#modules + 1] = module
    end
end

local function make_loader(use)
    return function(spec)
        local before_load = spec.__before_load
        local before_load_type = type(before_load)

        if before_load_type == "string" then
            vim.cmd(before_load)
        elseif before_load_type == "function" then
            before_load()
        end

        if xpcall(
                function() use(spec) end,
                function()
                    io.write("while loading: ")
                    vim.pretty_print(spec)
                    vim.notify(debug.traceback())
                end
            ) then
            loaded_plugin_list[#loaded_plugin_list + 1] = spec
        end
    end
end

local function turn_on_true_color()
    -- 开启真色彩
    if vim.fn.has "nvim" then
        vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    end

    if vim.fn.has "termguicolors" then
        vim.o.termguicolors = true
    end
end

local is_bootstranp, packer = require_packer()
local load = make_loader(packer.use)

function M.load_plugins(plugin_list)
    packer.startup(function()
        for _, plugin in ipairs(plugin_list) do
            load(plugin)
        end

        if is_bootstranp then
            packer.sync()
        else
            for _, spec in ipairs(loaded_plugin_list) do
                load_config(spec)
            end
        end
    end)
end

function M.finalize()
    utils.finalize(modules)
end

M.load_plugins {
    "wbthomason/packer.nvim",

    -- -------------------------------------------------------------------------
    -- General
    "lewis6991/gitsigns.nvim",
    { "ggandor/lightspeed.nvim",     disable = true },
    "scrooloose/nerdcommenter",
    {
        "nvim-tree/nvim-tree.lua",
        requires = { "nvim-tree/nvim-web-devicons" },
    },
    "tyru/open-browser.vim",
    "SirZenith/panelpal.nvim",
    {
        "SirZenith/vcs-helper.nvim",
        requires = { "SirZenith/panelpal.nvim" },
    },
    {
        "nvim-telescope/telescope.nvim",
        requires = { { "nvim-lua/plenary.nvim" } },
    },
    "voldikss/vim-floaterm",

    -- -------------------------------------------------------------------------
    -- Visual Assitance
    "Yggdroot/indentline",
    "nvim-lua/lsp-status.nvim",
    "SirZenith/nvim-cursorline",
    "p00f/nvim-ts-rainbow",
    { "norcalli/nvim-colorizer.lua", __before_load = turn_on_true_color },
    { "anuvyklack/pretty-fold.nvim", disable = true },

    -- -------------------------------------------------------------------------
    -- Themes
    { "catppuccin/nvim",             as = "catppuccin",                 disable = true },
    { "marko-cerovac/material.nvim", disable = true },
    { "kaicataldo/material.vim",     disable = true },
    {
        "EdenEast/nightfox.nvim",
        disable = false,
        __before_load = turn_on_true_color,
    },
    { "shaunsingh/nord.nvim",             disable = true },
    { "mhartington/oceanic-next",         disable = true },
    { "JoosepAlviste/palenightfall.nvim", disable = true },
    { "wadackel/vim-dogrun",              disable = true },
    { "rakr/vim-two-firewatch",           disable = true },
    -- after color scheme is loaded
    {
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
    },

    -- -------------------------------------------------------------------------
    -- Syntax
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/playground",

    "neovimhaskell/haskell-vim",
    "udalov/kotlin-vim",
    {
        "LhKipp/nvim-nu",
        requires = { "nvim-treesitter/nvim-treesitter" },
        run = ":TSInstall nu"
    },
    "aklt/plantuml-syntax",
    { "vim-pandoc/vim-pandoc-syntax", disable = true },

    -- -------------------------------------------------------------------------
    -- Language Support
    { "kevinhwang91/nvim-ufo",        requires = "kevinhwang91/promise-async" }, -- folding support
    {
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    },
    "neovim/nvim-lspconfig",
    {
        "jose-elias-alvarez/null-ls.nvim", -- LSP injection
        requires = { { "nvim-lua/plenary.nvim" } },
    },
    "weirongxu/plantuml-previewer.vim",
    "rust-lang/rust.vim",
    { "fatih/vim-go",            disable = true },
    { "scrooloose/vim-slumlord", disable = true }, -- PlantUML in-vim preview
    "lervag/vimtex",
    "stevearc/vim-arduino",
    "sudar/vim-arduino-syntax",
    "vim-voom/VOoM",

    -- -------------------------------------------------------------------------
    -- Completion
    "windwp/nvim-autopairs",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/nvim-cmp",

    -- -------------------------------------------------------------------------
    -- Snippet
    "L3MON4D3/LuaSnip",
}

return M
