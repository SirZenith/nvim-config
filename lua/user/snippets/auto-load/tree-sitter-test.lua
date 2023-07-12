local utils = require "user.utils"

local arg_list_check = utils.arg_list_check

local snip_filetype = "tree-sitter-test"
local s = require("user.snippets.util")
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

---@param args string[]
---@return Node[] | nil
---@return string | nil err
local function new_test(args)
    local err, name = arg_list_check(args, "name")
    if err then return nil, err end

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
end

s.command_snip(asp, nil, {
    new = {
        test = new_test,
    }
})
