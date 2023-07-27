---@return { normal: string, light: string, dark: string }
local function new_shade(normal, light, dark)
    return {
        dark = dark,
        normal = normal,
        light = light,
    }
end

local color = {
    black   = new_shade("#3b4252", "#465780", "#353a45"),
    red     = new_shade("#bf616a", "#d06f79", "#a54e56"),
    green   = new_shade("#a3be8c", "#b1d196", "#8aa872"),
    yellow  = new_shade("#ebcb8b", "#f0d399", "#d9b263"),
    blue    = new_shade("#81a1c1", "#8cafd2", "#668aab"),
    magenta = new_shade("#b48ead", "#c895bf", "#9d7495"),
    cyan    = new_shade("#88c0d0", "#93ccdc", "#69a7ba"),
    white   = new_shade("#e5e9f0", "#e7ecf4", "#bbc3d4"),
    orange  = new_shade("#c9826b", "#d89079", "#b46950"),
    pink    = new_shade("#bf88bc", "#d092ce", "#a96ca5"),

    comment = "#60728a",

    bg      = {
        darker   = "#15181e",
        dark     = "#232831", -- Dark bg (status line and float)
        normal   = "#2e3440", -- Default bg
        light    = "#39404f", -- Lighter bg (colorcolm folds)
        lighter  = "#444c5e", -- Lighter bg (cursor line)
        lightest = "#5a657d", -- Conceal, border fg
    },

    fg      = {
        light     = "#c7cdd9", -- Lighter fg
        normal    = "#cdcecf", -- Default fg
        dark      = "#abb1bb", -- Darker fg (status line)
        darker    = "#7e8188", -- Darker fg (line numbers, fold colums)
        darkest   = "#61646b",
        ignorable = "#808080"  -- Dark ignorable text
    },

    sel     = {
        darker = "#353c4a", -- Cursor line highlight
        dark   = "#3e4a5b", -- Popup bg, visual selection bg
        normal = "#3a4657", -- Visual mode
        light  = "#4f6074", -- Popup sel bg, search bg
    },
}

local highlight = {
    __new_entry = true,
    CursorLine = {
        bg = color.sel.darker,
    },
    DiffChange = {
        bg = color.sel.normal,
        fg = color.yellow.normal,
    },
    DiffCommon = {
        fg = color.fg.ignorable,
    },
    DiffDelete = {
        bg = color.sel.normal,
        fg = color.red.normal,
    },
    DiffInsert = {
        bg = color.sel.normal,
        fg = color.green.normal,
    },
    Folded = {
        fg = "#7e828c",
        bg = "#282d38",
    },
    LspLogTrace = {
        bg = color.sel.dark,
    },
    LspLogDebug = {
        bg = color.sel.light,
    },
    LspLogInfo = {
        fg = color.black.normal,
        bg = color.green.normal,
    },
    LspLogWarn = {
        fg = color.black.normal,
        bg = color.yellow.normal,
    },
    LspLogError = {
        fg = color.white.normal,
        bg = color.red.normal,
    },
    -- ------------------------------------------------------------------------
    LuaSnipInsertHint = {
        fg = color.yellow.normal,
    },
    LuaSnipChoiceHint = {
        fg = color.green.normal,
    },
    -- ------------------------------------------------------------------------
    PanelpalSelect = {
        fg = color.yellow.normal,
    },
    PanelpalUnselect = {
        fg = color.sel.light,
    },
    -- ------------------------------------------------------------------------
    -- Tab Line Style
    TabBar = {
        bg = color.bg.dark,
    },
    TabIcon = {
        fg = color.fg.darker,
        bg = color.bg.light,
    },
    TabStatus = {
        fg = color.fg.dark,
        bg = color.bg.lighter,
    },
    TabInactive = {
        fg = color.fg.darker,
        bg = color.bg.dark,
    },
    TabActive = {
        fg = color.bg.normal,
        bg = color.blue.normal,
    },
    TabSign = {
        fg = color.fg.light,
        bg = color.bg.dark,
    },
    TabSignActive = {
        fg = color.fg.light,
        bg = color.blue.normal,
    },
    TabStatusSign = {
        fg = color.fg.dark,
        bg = color.bg.lighter,
    },
    TabStatusSignActive = {
        fg = color.fg.light,
        bg = color.bg.lighter,
    },
    -- ------------------------------------------------------------------------
    Visual = {
        bg = color.sel.normal,
    },
}

local completion = {
    Pmenu = {
        fg = color.fg.dark,
        bg = color.bg.light,
    },
    PmenuSel = {
        fg = color.green.light,
        bg = color.bg.dark,
        bold = true,
    },

    CmpItemAbbr = {
        fg = color.fg.normal,
        bg = "NONE",
    },
    CmpItemAbbrDeprecated = {
        fg = color.ignorable,
        bg = color.bg.normal,
        strikethrough = true
    },
    CmpItemAbbrMatch = {
        fg = color.blue.light,
        bg = color.bg.light,
        bold = true
    },
    CmpItemAbbrMatchFuzzy = {
        fg = color.blue.light,
        bg = color.bg.light,
        bold = true
    },
    -- completion item kind highlight
    CmpItemMenu = {
        fg = color.fg.darkest,
        bg = "NONE",
    },

    CmpItemKindField = {
        fg = "#EED8DA",
        bg = color.red.dark,
    },
    CmpItemKindProperty = {
        fg = "#EED8DA",
        bg = color.red.dark,
    },
    CmpItemKindEvent = {
        fg = "#EED8DA",
        bg = color.red.dark,
    },

    CmpItemKindText = {
        fg = "#e5edde",
        bg = color.green.dark,
    },
    CmpItemKindEnum = {
        fg = "#e5edde",
        bg = color.green.dark,
    },
    CmpItemKindKeyword = {
        fg = "#e5edde",
        bg = color.green.dark,
    },

    CmpItemKindConstant = {
        fg = "#f8ecd3",
        bg = color.yellow.dark,
    },
    CmpItemKindConstructor = {
        fg = "#f8ecd3",
        bg = color.yellow.dark,
    },
    CmpItemKindReference = {
        fg = "#f8ecd3",
        bg = color.yellow.dark,
    },

    CmpItemKindFunction = {
        fg = "#EADFF0",
        bg = color.magenta.dark,
    },
    CmpItemKindStruct = {
        fg = "#EADFF0",
        bg = color.magenta.dark,
    },
    CmpItemKindClass = {
        fg = "#EADFF0",
        bg = color.magenta.dark,
    },
    CmpItemKindModule = {
        fg = "#EADFF0",
        bg = color.magenta.dark,
    },
    CmpItemKindOperator = {
        fg = "#EADFF0",
        bg = color.magenta.dark,
    },

    CmpItemKindVariable = {
        fg = "#C5CDD9",
        bg = "#7E8294"
    },
    CmpItemKindFile = {
        fg = "#C5CDD9",
        bg = "#7E8294"
    },

    CmpItemKindUnit = {
        fg = "#F5EBD9",
        bg = color.yellow.dark,
    },
    CmpItemKindSnippet = {
        fg = "#F5EBD9",
        bg = color.yellow.dark,
    },
    CmpItemKindFolder = {
        fg = "#F5EBD9",
        bg = color.yellow.dark,
    },

    CmpItemKindMethod = {
        fg = "#DDE5F5",
        bg = color.blue.dark,
    },
    CmpItemKindEnumMember = {
        fg = "#DDE5F5",
        bg = color.blue.dark,
    },

    CmpItemKindInterface = {
        fg = "#ece3df",
        bg = color.orange.dark
    },
    CmpItemKindColor = {
        fg = "#ece3df",
        bg = color.orange.dark
    },
    CmpItemKindTypeParameter = {
        fg = "#ece3df",
        bg = color.orange.dark
    },

    CmpItemKindValue = {
        fg = "#EED8DA",
        bg = color.pink.dark,
    },
}

highlight = vim.tbl_extend("keep", highlight, completion)

return highlight
