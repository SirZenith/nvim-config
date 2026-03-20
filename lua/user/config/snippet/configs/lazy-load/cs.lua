local snip_filetype = "cs"
local s = require "user.config.snippet.utils"
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
-- local psp = makers.psp
-- local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
-- local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

local cmd_snip = require "cmd-snippet"

cmd_snip.register(snip_filetype, {
    ["new doccom"] = {
        content = {
            "/// <summary>",
            { "/// ", 1 },
            "/// </summary>",
        },
    },
})
