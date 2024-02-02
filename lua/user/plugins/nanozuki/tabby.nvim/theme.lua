local highlight = require "user.config.general.highlight"

local color = highlight.color

return {
    line_bg = color.bg.darker,

    header = {
        fg = color.white.normal,
        bg = color.magenta.dark,
    },
    footer = {
        fg = color.black.normal,
        bg = color.orange.light,
    },

    tab = {
        fg = color.fg.darker,
        bg = color.bg.dark,
    },
    tab_active = {
        fg = color.bg.dark,
        bg = color.yellow.normal,
    },
    tab_fg_connector = color.bg.lightest,

    tab_icon = {
        fg = color.fg.dark,
        bg = color.bg.dark,
    },
    tab_icon_active = {
        fg = color.bg.dark,
        bg = color.yellow.normal,
    },

    win_tab = {
        fg = color.fg.dark,
        bg = color.bg.normal,
    },
    win_tab_active = {
        fg = color.bg.normal,
        bg = color.blue.normal,
    },
    win_tab_fg_connector = color.bg.lightest,

    win_tab_icon = {
        fg = color.fg.darker,
        bg = color.bg.normal,
    },
    win_tab_icon_active = {
        fg = color.bg.dark,
        bg = color.blue.normal,
    }
}
