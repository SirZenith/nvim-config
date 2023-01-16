-- snippets for writing snippets
local s = require("user.snippets.util")
local snip_filetype = "snippet"
local makers = s.snippet_makers(snip_filetype)
local apsp = makers.apsp

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
apsp("ssn", 's.sn(${1})')
apsp("srn", 's.r(${1})')
apsp("sdn", 's.d(${1})')

makers.finalize()
