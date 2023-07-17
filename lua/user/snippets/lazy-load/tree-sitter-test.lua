local utils = require "user.utils"
local cmd_snip = require "user.snippets.cmd-snippet"

local arg_list_check = utils.arg_list_check

local snip_filetype = "tree-sitter-test"
local s = require("user.snippets.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
local asp = makers.asp
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

cmd_snip.register {
    ["new test"] = {
        args = { "name" },
        content = function(name)
            local sep_len = 5
            local title_sep = ("="):rep(5)
            return {
                title_sep,
                name,
                title_sep,
                "",
                { 1 },
                "",
                ("-"):rep(sep_len),
                "",
                { 2 },
            }
        end,
    },
}
