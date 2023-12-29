local snip_filetype = "all"
local s = require("user-snippet.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
local asp = makers.asp
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

asp("sepline;", s.f(function()
    local line = vim.fn.getline(".")
    return ("-"):rep(79 - #line)
end))

apsp("raa", "-> ")
apsp("laa", "<- ")

apsp("rra", "=> ")
apsp("lla", "<= ")
