local user = require "user"
local highlight = require "user.config.general.highlight"

---@alias user.plugin.StartupTextTypeContent string[] | fun(): string[]
---@alias user.plugin.StartupMappingTypeContent string[][] # mapping display name to { [1] = display name, [2] = command,  [3] = keybinding }
---@alias user.plugin.StartupOldFilesTypeContent ""

---@class user.plugin.StartupSection
---@field type "text" | "mapping" | "oldfiles"
---@field title string # Title to display when folded.
---@field content user.plugin.StartupTextTypeContent | user.plugin.StartupMappingTypeContent | user.plugin.StartupOldFilesTypeContent
--
---@field align "center" | "left" | "right"
---@field fold_section? boolean # Fold this section by default.
---@field margin number # Margin value when using `left` or `right` alignment. Value less then 1 will be useed as percentage, otherwise used as number of columns.
--
---@field highlight string # Highlight group for section text.
---@field default_color string # Hex color for text when `highlight` is not given.
--
---@field oldfiles_directory boolean # Display old files in current directory.
---@field oldfiles_amount number # number of old files that should be listed on screen.

local ASCII_DRAWING = {
    "█████████████████████████▒▒░░▓███████████████████████████▓▓▓▓▓███████▓██████████████████████████████",
    "████████████████████▓▓▒▒░░░░░▒▒████████████▓▓█████▓▒░ ░░   ░▓██████████████████████████████████████▒",
    "█████████████████▒░░░ ░░░▒░▒▒▒▒▒▓▓▒███▓░      ▓███▓▒░░  ░▒██████▓▓██████████████████████████████████",
    "████████████▓▓▒██▓▒░░▒▒▒░▒▒▒░░▒▒▒███▒        ░█████████████████▓   ▒████████████████████████████████",
    "█████████░░░░░░░░▓█████▓▓▒▒▒▒▒▓███▓          ▒█████████████████▒     ▒██████████████████████████████",
    "██████▒░░░░░░░▒▒▒▒██▒▒▓▓██▓▓▓████▓         ▒███████████████████░      ░█████████████████████████████",
    "██▓▒▒█▓░ ░▒▒▒▒▒▒▒▒██░░ ░░▒███████░       ░██████████████████████░      ░████████████████████████████",
    "▒▒░░▒▓█▓▒▒▒▒▒▒▓▒▒██▒░  ▒█████████        ████████████████████████       ████████████████████████████",
    "░▒▒▒▓▒██▒░▒▒▒░░▒▓█▓░░░▓██████████        ████████████████████████▒      ▓███████████████████████████",
    "▒▒▒▒▒▒▓█▒▒▒░ ░░▓█▓▒▒▓████████████░       ▓███████████████████████▒      ▓███████████████████████████",
    "░░▒▒▒ ▒▓▒▒░░░▒█▓▓▒▒▓█████████████▓        ▓███▓▓▒▒▒▒▒▒▒▒▓▓██████▓       ████████████████████████████",
    "▓▓▓▓▒░█▒░ ░▒▓▒░░▓█████████████████░                          ░▒░       ░████████████████████████████",
    "▓██▓▓▓▓▓▓███▓▓▓████████████████████░                                  ░████████████████████████▓▒░▒█",
    "▒░█▒ ░░░▒▒▒▓▓███████████████████████▒                                ▒████████████████▓▓▒▓▒▒███░ ░░░",
    "░▓█▓▓▓▓▓▒▒▒▒████████████████████████▒                               ▒█████████████▓▓▒▒▒░▒░  ▒██▓░▒░░",
    "▒██▒▓▓▓▓▓▓██████████████████████████                                ░████████████▓▓▒▒▒░░░   ░███▒▒▒▒",
    "▓███▓▓███▓██████████████████████████           ▓████░                ████████▓▒▓▓██▓▒ ░░░▒▒▒▒▓██▒▒▒▒",
    "███████████████████████████████████▓          ███████          ▓██░  ███████▒▒░░░░▒▓██▓░░▒▒▒▒▓██▓▓▒░",
    "█░█████████████████████████████████▓         ░███████         ▓████  █████▒░░   ░░░░▒▓█▓▒▒▒▓▓▒██▒░░▒",
    "██████████▓▒███████████████████████▓         ░███████         █████  ████▒░░ ░░░░░▒▓▓▓▓██▓▒▒▒░█▓░▒▒▓",
    "██████▒▓███████████▒▒███████████████          ▒█████░         █████ ░████▓▒▒░▒▒▓▒▓███▓▒▓▓▒▒▒▒▒█▒▓▓▓▓",
    "███████████████████████████████████▓            ▒▒░           ▓███░ ▒███████████████▓░▒▒░░░▒▒▓▓▓▓▓██",
    "██████████████████████████████████                             ░░   ██████████████▓▓▓▓▓▓▒▓▓▓▓███████",
    "██████████████████████████████████▒                                ▓█████████▓██▓▒▒▒▒▓▓▓▓███████████",
    "████████████████████████████████████                              ▒██████████▓▒░░░▒▓▓▓██▒███████████",
    "█▓▓██████████████████████████████████                           ▒████████████▓░░▒▒▓▓████████████████",
    "███████████████████████████████████▓                       ▒▓█████████████████▒▓████████████████████",
    "████████████████████████████████████░                      ▒████████████████████████████████████████",
    "██████████████▓███████████████████████░                     ████████████████████████████████████████",
    "███████▓█████████████████████████████▓                      ▓███████████████████████████████████████",
    "██████▒▒██████████████▒█████████████▒                       ▒███████████████████████████████████████",
    "████████████████████████████▓▒▒▒▒▒                          ░███████████████████████████████████████",
    "████████████████████████████▓                                ██████████████████████▓████████████████",
    "█████████████████████████████▒                              ░█████████████████▓█████████████████████",
    "████████████████████████████░                               ▓███████████████████████████████████████",
    "███████████████████████████▓  ░▒░                           ████████████████████████████████████▓▒▒░",
    "███████████████████████████████▓                            ███████████████████████▓████████▓▒▒▒▒▒▒░",
    "██████████████████████████████▓▒░░░                        ░████████████████████████▓▓▒▒▓████▓     ▒",
    "████████▓░░███████████████████████▓ ░░                      ▓█████████████████████████████▓▒░░░▒▒▓██",
    "█████▒  ░▓███████████████████████████████▒     ░▒▓░       ▓▒▒███████████████████████████▒░ ░░░▒▓▓▓▒▒",
    "███▒  ░▓██████████████████████████████████     ███    ░█░▓████▓██████████████████████████████████▓▒▓",
    "█░   ▓████▓▒▒░░░░░░░░░▒▓▓▓████████████████▓    ██▓   ░███████████████████████▓▓▓▓▒▒▒▒▒▒▒▒▓██████████",
    "   ▒██▓░ ░      ░░░░░░░▒▒▒▓▓████▓▒▒░░░░              ▓▓██████████████▓▓▒░░░░░░░░    ░ ░░░░▒░░▒▒▓▓███",
    " ░█▓░      ░░░░░░░▒▓▓███████▓▒          ░▒▒               ▒▓███████▓▒▒▒▒░░░░░░░ ░░░▒░░▒▒▒░░░      ░▒",
    "░█▓░░░▒░▒▒▒▓▓▓▓███████████▓░           ░ ░▒▓             ▒░  ░▓██████▓█▓▓▓▓▓▓▓▒▓▓▓▒▒▒▒▒░░░░░░░░░ ░░ ",
    "██▓█████████████████████▓                ▓░░█             ▒▒    ▓████████████████████████████▓▒░  ░░",
    "███████████████████████▓ ▒▒▓▒░░░▒▒▒▓▓▓▒▒▒▒█░▓▒             ▒█░   ░██████████████████████████████████",
    "███████████████████████▓██████████████████████░             ▓█░░   ▒███████████████████████████████▓",
    "█████████▓▒▒░░░░               ░░▒▒▓▓██████████░   ░▒▓▓▒▒▒░ ░█▒     ▓████████████████████████▓▒▒░   ",
    "███▓▒░   ░░░░░░░░░░░░                  ░▒▓████████████████████████████████████████▓██████▓▒░        ",
}

user.plugin.startup_nvim = {
    __new_entry = true,
    colors = {
        background = highlight.color.bg.normal,
        folded_section = highlight.color.fg.darker,
    },
    mappings = {
        execute_command = "<CR>",
        open_file = "o",
        open_file_split = "<c-o>",
        open_section = "<TAB>",
        open_help = "?",
    },
    options = {
        -- display mapping (e.g. <leader>ff)
        mapping_keys = false,

        -- if < 1 fraction of screen width
        -- if > 1 numbers of column
        cursor_column = 0.38,

        -- function that gets executed at the end
        after = function() end,
        -- add an empty line between mapping/commands
        empty_lines_between_mappings = true,
        -- disable status-, buffer- and tablines
        disable_statuslines = true,
        -- amount of empty lines before each section (must be equal to amount of sections)
        paddings = { 2, 4 },
    },

    -- List all section keys in order
    parts = { "section_drawing", "section_action" },
    -- Write as many sections as you like.
    ---@type user.plugin.StartupSection
    section_drawing = {
        type = "text",
        title = "",
        content = ASCII_DRAWING,

        align = "center",
        fold_section = false,
        margin = 0,

        highlight = "",
        default_color = highlight.color.white.normal,

        oldfiles_amount = 0,
        oldfiles_directory = false,
    },
    ---@type user.plugin.StartupSection
    section_action = {
        type = "mapping",
        title = "Quick Actions",
        content = {
            { "               Find File", "Telescope find_files", "<leader>ff" },
            { "               Recent Files", "Telescope oldfiles", "<leader>of" },
            { "               Colorschemes", "Telescope colorscheme", "<leader>cs" },
            { "               New File", "lua require 'startup'.new_file()", "<leader>nf" },
        },

        align = "center",
        fold_section = false,
        margin = 0,

        highlight = "",
        default_color = highlight.color.yellow.normal,

        oldfiles_amount = 0,
        oldfiles_directory = false,
    },
}

return function()
    local startup = require "startup"

    startup.setup(user.plugin.startup_nvim())
    startup.display()
end
