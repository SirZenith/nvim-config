local snip_filetype = "snippet"
local s = require("user.snippets.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
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
local snip_filetype = "${1:all}"
local s = require("user.snippets.utils")
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

apsp("cond-snippet-init;", [[
local snip_filetype = "${1:all}"
local s = require("user.snippets.utils")
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

apsp("nsp", 'sp("${1}", ${0})')
apsp("nasp", 'asp("${1}", ${0})')
apsp("npsp", 'psp("${1}", ${0})')
apsp("napsp", 'apsp("${1}", ${0})')

apsp("resp", 'regsp("${1}", ${0})')
apsp("reasp", 'regasp("${1}", ${0})')
apsp("repsp", 'regpsp("${1}", ${0})')
apsp("reapsp", 'regapsp("${1}", ${0})')

apsp("cdsp", 'condsp(${1}, "${2}", ${0})')
apsp("cdasp", 'condasp(${1}, "${2}", ${0})')
apsp("cdpsp", 'condpsp(${1}, "${2}", ${0})')
apsp("cdapsp", 'condapsp(${1}, "${2}", ${0})')

apsp("stn", 's.t("${1}")')
apsp("sin", 's.i(${1})')
apsp("sfn", 's.f(${1})')
apsp("scn", 's.c(${1})')
apsp("ssn", 's.s(${1})')
apsp("sps", 's.ps(${1})')
apsp("srn", 's.r(${1})')
apsp("sdn", 's.d(${1})')

apsp("new-cmd-snip", [[
["${1:cmd}"] = cmd_snip.cmd_item {
    content = ${0}
}
]])
