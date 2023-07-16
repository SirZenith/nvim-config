local M = {}

M.event = "BufRead"
M.pattern = "*/tree-sitter-*/grammar.js"
M.cond_func = nil

local RULE_INIT = [[
module.exports = grammar({
    name: '${1}',

    rules: {
        // TODO: add the actual grammar rules
        source_file: $ => '${0}'
    }
});
]]

function M.setup()
    local snip_filetype = "all"
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

    apsp("rule-init;", RULE_INIT)
end

return M
