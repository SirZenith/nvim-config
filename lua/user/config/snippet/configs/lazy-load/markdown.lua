local cmd_snip = require "cmd-snippet"

local snip_filetype = "markdown"
local s = require "user.config.snippet.utils"
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
-- local psp = makers.psp
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

apsp("imt", "\\$$1\\$ $0")
apsp("dmt", [[
\$\$
    $1
.\$\$ $0
]])

-- ----------------------------------------------------------------------------

cmd_snip.register(snip_filetype, {
    b = {
        arg = { "text" },
        content = function(text)
            return "<b>" .. text .. "</b>"
        end
    },
    img = {
        args = { "title", "url" },
        content = function(title, url)
            return ("![%s](%s)"):format(title, url)
        end
    },
    link = {
        args = { "title", "url" },
        content = function(title, url)
            return ("[%s](%s)"):format(title, url)
        end
    },
    ruby = {
        args    = { "text_list", "annotation_list" },
        content = function(text_list, annotation_list)
            local text_parts = vim.split(text_list, "|", { plain = true })
            local anno_parts = vim.split(annotation_list, "|", { plain = true })
            local buffer = { "<ruby>" }

            for i = 0, #text_parts do
                local text = text_parts[i]
                local annotation = anno_parts[i]

                local result = text
                if annotation and annotation ~= "" then
                    result = ("%s<rp>(</rp><rt>%s</rt><rp>)</rp>"):format(text, annotation)
                end

                table.insert(buffer, result)
            end

            table.insert(buffer, "</ruby>")

            return table.concat(buffer, "")
        end,
    },
})
