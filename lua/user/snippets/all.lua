# vim:ft=lua.snippet

local snip_filetype = "all"
local s = require("user.snippets.util")
local makers = s.snippet_makers(snip_filetype)
local sp = makers.sp
-- local asp = makers.asp
-- local psp = makers.psp
local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
-- local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp("snip-init;", [[
# vim:ft=lua.snippet

local snip_filetype = "${1:all}"
local s = require("user.snippets.util")
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

${0}
]])

sp("sepline", s.t({ string.rep("-", 77) }))

apsp("raa", "-> ")
apsp("laa", "<- ")

apsp("rra", "=> ")
apsp("lla", "<= ")
