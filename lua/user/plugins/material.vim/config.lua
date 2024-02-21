local user = require "user"

local styles = {
    "default",
    "ocean",
    "palenight",
    "lighter",
    "darker",
    "default-community",
    "palenight-community",
    "ocean-community",
    "darker-community",
    "lighter-community",
}

user.general.option.g = {
    material_theme_style = styles[6],
    material_terminal_italics = 1,
    airline_theme = "material",
}

user.general.theme.colorscheme = "material"
