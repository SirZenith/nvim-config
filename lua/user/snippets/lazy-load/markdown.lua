local snip_filetype = "markdown"
local s = require("snippet-loader.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
local psp = makers.psp
local apsp = makers.apsp

-- local condsp = makers.condsp
local condasp = makers.condasp
-- local condpsp = makers.condpsp
local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp("incd", "`$1` $0")
condapsp(s.conds.line_begin, "cbl", [[
```$1
$0
```
]])
condasp(s.conds.line_begin, { trig = "([#%w]+)cbl", regTrig = true }, {
    s.t("```"), s.f(function(_, snip) return snip.captures[1] end, {}),
    s.t({ "", "" }), s.i(0),
    s.t({ "", "```" }),
})

condasp(
    s.conds.line_begin,
    { trig = "(hh-)l", regTrig = true },
    s.f(function(_, snip)
        local len = #snip.captures[1]
        return ("#"):rep(len) .. " "
    end)
)

psp("link", "[$1](${2:$TM_SELECTED_TEXT}) $0")
psp("img", "![$1](${2:$TM_SELECTED_TEXT}) $0")

apsp("imt", "\\$$1\\$ $0")
apsp("dmt", [[
\$\$
    $1
.\$\$ $0
]])
