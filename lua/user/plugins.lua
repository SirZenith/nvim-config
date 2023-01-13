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

    local file = fs.path_join(user.env.CONFIG_HOME(), path .. ".lua")
    if fn.filereadable(file) ~= 0 then
        local module = import(path)
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
                print(debug.traceback())
            end
        ) then
            loaded_plugin_list[#loaded_plugin_list+1] = spec
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

packer.startup(function(use)
    local load = make_loader(use)

    load "wbthomason/packer.nvim"

    -- -------------------------------------------------------------------------
    -- General
    load "lewis6991/gitsigns.nvim"
    load { "ggandor/lightspeed.nvim", disable = true }
    load "scrooloose/nerdcommenter"
    load {
        "nvim-tree/nvim-tree.lua",
        requires = { "nvim-tree/nvim-web-devicons" },
    }
    load "tyru/open-browser.vim"
    load {
        "nvim-telescope/telescope.nvim",
        requires = { { "nvim-lua/plenary.nvim" } },
    }
    load "voldikss/vim-floaterm"

    -- -------------------------------------------------------------------------
    -- Visual Assitance
    load "Yggdroot/indentline"
    load "nvim-lua/lsp-status.nvim"
    load "SirZenith/nvim-cursorline"
    load "p00f/nvim-ts-rainbow"
    load { "norcalli/nvim-colorizer.lua", __before_load = turn_on_true_color }
    load { "anuvyklack/pretty-fold.nvim", disable = true }

    -- -------------------------------------------------------------------------
    -- Themes
    load { "catppuccin/nvim", as = "catppuccin", disable = true }
    load { "marko-cerovac/material.nvim", disable = true }
    load { "kaicataldo/material.vim", disable = true }
    load {
        "EdenEast/nightfox.nvim", disable = false,
        __before_load = turn_on_true_color,
    }
    load { "shaunsingh/nord.nvim", disable = true }
    load { "mhartington/oceanic-next", disable = true }
    load { "JoosepAlviste/palenightfall.nvim", disable = true }
    load { "wadackel/vim-dogrun", disable = true }
    load { "rakr/vim-two-firewatch", disable = true }
    -- after color scheme is loaded
    load {
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
    }

    -- -------------------------------------------------------------------------
    -- Syntax
    load "nvim-treesitter/nvim-treesitter"
    load "nvim-treesitter/playground"

    load "neovimhaskell/haskell-vim"
    load "udalov/kotlin-vim"
    load {
        "LhKipp/nvim-nu",
        requires = { "nvim-treesitter/nvim-treesitter" },
        run = ":TSInstall nu"
    }
    load "aklt/plantuml-syntax"
    load { "vim-pandoc/vim-pandoc-syntax", disable = true }

    -- -------------------------------------------------------------------------
    -- Language Support
    load { "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" } -- folding support
    load {
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    }
    load "neovim/nvim-lspconfig"
    load {
        "jose-elias-alvarez/null-ls.nvim", -- LSP injection
        requires = { { "nvim-lua/plenary.nvim" } },
    }
    load "weirongxu/plantuml-previewer.vim"
    load "rust-lang/rust.vim"
    load { "fatih/vim-go", disable = true }
    load { "scrooloose/vim-slumlord", disable = true } -- PlantUML in-vim preview
    load "lervag/vimtex"
    load "stevearc/vim-arduino"
    load "sudar/vim-arduino-syntax"
    load "vim-voom/VOoM"

    -- -------------------------------------------------------------------------
    -- Completion
    load "windwp/nvim-autopairs"
    load "hrsh7th/cmp-buffer"
    load "hrsh7th/cmp-cmdline"
    load "saadparwaiz1/cmp_luasnip"
    load "hrsh7th/cmp-nvim-lsp"
    load "hrsh7th/cmp-path"
    load "hrsh7th/nvim-cmp"

    -- -------------------------------------------------------------------------
    -- Snippet
    load "L3MON4D3/LuaSnip"

    if is_bootstranp then
        packer.sync()
    else
        for _, spec in ipairs(loaded_plugin_list) do
            load_config(spec)
        end
    end
end)

function M.finalize()
    utils.finalize(modules)
end

return M
