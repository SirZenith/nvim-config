local snip_filetype = "plantuml"
local s = require("user-snippet.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
local psp = makers.psp
local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp("begg", [[
@start${1:uml}

${0}

@end${1}
]])

-- ----------------------------------------------------------------------------
-- Macro
apsp("linefunc", "!function $${1:name}() ${2} return ${0:value}")
apsp("newfunc", [[
!function $${1:name}(${2})
${0}
!endfunction
]])
apsp("newproc", [[
!procedure $${1:name}(${2})
${0}
!endprocedure
]])

psp("inc", "!include ${0:path}")
psp("imp", "!import ${0:path}")

psp("def", "!$${1:name} = ${0:1}")
apsp("ifdef", [[
!if %variable_exists("$${1:name}")
    ${0}
!endif
]])
apsp("ifndef", [[
!if %not(%variable_exists("$${1:name}"))
${0}
!endif
]])
-- ----------------------------------------------------------------------------
-- Styling
psp("sty", [[
<style>

${0}

</style>
]])
apsp("styclass", [[
.${1:name} {{
    ${0}
}}
]])
apsp("usesty", "<<${0:name}>>")
psp("bg", "BackgroundColor ${0:White}")


-- ----------------------------------------------------------------------------
-- Sequence Diagram
apsp("msend", "${1} -> ${2} : ${0}")

-- ----------------------------------------------------------------------------
-- Mindmap
condapsp(s.conds.line_begin, "ml", "* ")
condapsp(s.conds.line_begin, "mml", "** ")
condapsp(s.conds.line_begin, "mmml", "*** ")
condapsp(s.conds.line_begin, "mmmml", "**** ")
condapsp(s.conds.line_begin, "mmmmml", "***** ")
condapsp(s.conds.line_begin, "mmmmmml", "****** ")

psp("color", "[#${1:Black}]")
