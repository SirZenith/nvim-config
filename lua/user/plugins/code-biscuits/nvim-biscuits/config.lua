local user = require "user"

user.plugin.nvim_biscuits = {
    __new_entry = true,
    -- Minimum row distance between beginning and ending of scope required to
    -- show virtual text.
    ---@type number
    min_distance = 5,
    -- Maximum length of virtual text.
    ---@type number
    max_length = 30,
    -- Truncate virtual text content by word when content overlong instaed of by
    -- character.
    ---@type boolean
    trim_by_words = false,

    ---@type string
    prefix_string = "  ",

    -- Show virtual text right after buffer gets loaded.
    ---@type boolean
    show_on_start = false,
    -- Only show virtual on cursor line.
    ---@type boolean
    cursor_line_only = true,

    -- Show virtual text after certain event.
    ---@type string[]
    on_events = {
        "InsertLeave",
        "CursorHold",
        "CursorHoldI",
    },

    language_config = {
        help = {
            disabled = true,
        },
    },
}

return function()
    require "nvim-biscuits".setup(user.plugin.nvim_biscuits())
end
