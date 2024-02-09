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
        -- Dark bg (status line and float)
        dark     = "#232831",
        -- Default bg
        normal   = "#2e3440",
        -- Lighter bg (colorcolm folds)
        light    = "#39404f",
        -- Lighter bg (cursor line)
        lighter  = "#444c5e",
        -- Conceal, border fg
        lightest = "#5a657d",
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

local highlight = vim.tbl_extend("keep", {
    __new_entry = true,
}, {
    -- ------------------------------------------------------------------------
    -- General
    CursorLine = {
        bg = color.sel.darker,
    },
    Folded = {
        fg = "#7e828c",
        bg = "#282d38",
    },
    Visual = {
        bg = color.sel.normal,
    },
}, {
    -- ------------------------------------------------------------------------
    -- Diff
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
}, {
    -- ------------------------------------------------------------------------
    -- LSP log
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
}, {
    -- ------------------------------------------------------------------------
    -- LuaSnip
    LuaSnipInsertHint = {
        fg = color.yellow.normal,
    },
    LuaSnipChoiceHint = {
        fg = color.green.normal,
    },
}, {
    -- ------------------------------------------------------------------------
    -- Panelpal
    PanelpalSelect = {
        fg = color.yellow.normal,
    },
    PanelpalUnselect = {
        fg = color.sel.light,
    },
}, {
    -- ------------------------------------------------------------------------
    -- Completion
    Pmenu = {
        fg = color.fg.dark,
        bg = color.bg.light,
    },
    PmenuSel = {
        fg = color.bg.dark,
        bg = color.green.normal,
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
}, {
    -- ------------------------------------------------------------------------
    -- mongosh.nvim
    MongoshNormal = {
        fg = color.fg.normal,
        bg = color.bg.dark,
    },

    MongoshHostName = {
        fg = color.orange.normal,
    },
    MongoshHostSymbol = {
        fg = color.orange.normal,
    },

    MongoshDatabaseName = {
        fg = color.blue.normal,
    },
    MongoshDatabaseSymbol = {
        fg = color.cyan.normal,
    },

    MongoshCollectionName = {
        fg = color.fg.normal,
    },
    MongoshCollectionSymbol = {
        fg = color.yellow.normal,
    },

    MongoshCollectionLoading = {
        fg = color.fg.normal,
    },
    MongoshCollectionLoadingSymbol = {
        fg = color.green.normal
    },

    MongoshTreeNormal = {
        fg = color.fg.normal,
    },

    MongoshValueTypeName = {
        fg = color.fg.darker,
    },

    MongoshValueArray = {
        fg = color.yellow.normal
    },
    MongoshValueBoolean = {
        fg = color.orange.normal,
    },
    MongoshValueNull = {
        fg = color.orange.normal,
    },
    MongoshValueNumber = {
        fg = color.orange.normal,
    },
    MongoshValueString = {
        fg = color.green.normal,
    },
    MongoshValueObject = {
        fg = color.cyan.light,
    },
    MongoshValueOmited = {
        fg = color.fg.ignorable,
    },
    MongoshValueRegex = {
        fg = color.yellow.normal
    },
    MongoshValueUnknown = {
        fg = color.white.normal,
        bg = color.red.normal,
    },
}, {
    -- ------------------------------------------------------------------------
    -- nvim-dap
    DapBreakpoint = {
        fg = color.yellow.normal,
    },
    DapBreakpointCondition = {
        fg = color.orange.normal,
    },
    DapLogPoint = {
        fg = color.blue.normal,
    },
    DapStopped = {
        fg = color.green.normal,
    },
    DapStoppedLine = {
        bg = color.sel.darker,
    },
    DapBreakpointRejected = {
        fg = color.red.normal,
    },
}, {
    -- ------------------------------------------------------------------------
    -- indent-blankline.nvim
    RainbowRed = {
        fg = color.red.normal,
    },
    RainbowYellow = {
        fg = color.yellow.normal,
    },
    RainbowBlue = {
        fg = color.blue.normal,
    },
    RainbowOrange = {
        fg = color.orange.normal,
    },
    RainbowGreen = {
        fg = color.green.normal,
    },
    RainbowViolet = {
        fg = color.magenta.normal,
    },
    RainbowCyan = {
        fg = color.cyan.normal,
    },
}, {
    -- ------------------------------------------------------------------------
    -- nvim-biscuit
    BiscuitColor = {
        fg = color.fg.ignorable,
    },
}, {
    -- ------------------------------------------------------------------------
    -- lsp-status
    LspStatusIndicatorHint = {
        fg = color.green.normal,
        bg = color.bg.dark,
    },
    LspStatusIndicatorInfo = {
        fg = color.blue.normal,
        bg = color.bg.dark,
    },
    LspStatusIndicatorWarnings = {
        fg = color.yellow.normal,
        bg = color.bg.dark,
    },
    LspStatusIndicatorErrors = {
        fg = color.red.normal,
        bg = color.bg.dark,
    },
    LspStatusSpinner1 = {
        fg = color.green.normal,
        bg = color.bg.dark,
    },
    LspStatusSpinner2 = {
        fg = color.yellow.normal,
        bg = color.bg.dark,
    },
    LspStatusSpinner3 = {
        fg = color.blue.normal,
        bg = color.bg.dark,
    },
})

local rainbow_hl_groups = {
    "RainbowBlue",
    "RainbowGreen",
    "RainbowYellow",
    "RainbowOrange",
    "RainbowViolet",
    "RainbowCyan",
    "RainbowRed",
}

local rainbow_colors = {}
for _, name in ipairs(rainbow_hl_groups) do
    local cfg = highlight[name]
    rainbow_colors[#rainbow_colors + 1] = cfg.fg or "#FFFFFF"
end

local M = {
    color = color,
    highlight = highlight,
    rainbow_hl_groups = rainbow_hl_groups,
    rainbow_colors = rainbow_colors,
}

return M
