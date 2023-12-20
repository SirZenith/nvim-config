local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

local styles = {
    "darker",
    "lighter",
    "oceanic",
    "palenight",
    "deep ocean",
}

user.option.g = {
    material_style = styles[3]
}

user.theme.colorscheme = "material"
user.theme.lualine_theme = "material-nvim"

user.plugin.material_nvim = {
    __new_entry = true,
    contrast = true,       -- Enable contrast for sidebars, floating windows and popup menus like Nvim-Tree
    borders = true,        -- Enable borders between verticaly split windows
    popup_menu = "dark",   -- Popup menu style ( can be: 'dark', 'light', 'colorful' or 'stealth' )
    italics = {
        comments = false,  -- Enable italic comments
        keywords = false,  -- Enable italic keywords
        functions = false, -- Enable italic functions
        strings = false,   -- Enable italic strings
        variables = false  -- Enable italic variables
    },
    contrast_windows = {   -- Specify which windows get the contrasted (darker) background
        "terminal",        -- Darker terminal background
        "packer",          -- Darker packer background
        "qf"               -- Darker qf list background
    },
    text_contrast = {
        lighter = false, -- Enable higher contrast text for lighter style
        darker = false,  -- Enable higher contrast text for darker style
    },
    disable = {
        background = false,  -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
        term_colors = false, -- Prevent the theme from setting terminal colors
        eob_lines = false    -- Hide the end-of-buffer lines
    },
    custom_highlights = {}   -- Overwrite highlights with your own
}

local function finalize(module)
    module.setup(user.plugin.material_nvim())
end

return wrap_with_module("material", finalize)
