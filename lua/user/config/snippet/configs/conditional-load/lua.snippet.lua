local user = require "user"
local fs_util = require "user.util.fs"

local snip_filetype = "lua"
local s = require "user.config.snippet.utils"
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

local M = {}

M.event = "FileType"
M.pattern = "lua"

M.cond_func = function()
    local cwd = vim.fn.getcwd()
    return fs_util.is_subdir_of(cwd, user.env.USER_RUNTIME_PATH())
end

function M.setup()
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

    local cmd_snip = require "cmd-snippet"

    cmd_snip.register(snip_filetype, {
        ["init cmd-snip"] = {
            content = {
                "local cmd_snip = require \"cmd-snippet\"",
                "",
                "cmd_snip.register(snip_filetype, {",
                "})",
            },
        },
        ["init cond-snip"] = {
            args = { { "file-type" }, },
            content = function(file_type)
                return {
                    { "local snip_filetype = \"", file_type, "\"" },
                    "local s = require \"user.config.snippet.utils\"",
                    "local makers = s.snippet_makers(snip_filetype)",
                    "-- local sp = makers.sp",
                    "-- local asp = makers.asp",
                    "-- local psp = makers.psp",
                    "-- local apsp = makers.apsp",
                    "",
                    "-- local condsp = makers.condsp",
                    "-- local condasp = makers.condasp",
                    "-- local condpsp = makers.condpsp",
                    "-- local condapsp = makers.condapsp",
                    "",
                    "-- local regsp = makers.regsp",
                    "-- local regasp = makers.regasp",
                    "-- local regpsp = makers.regpsp",
                    "-- local regapsp = makers.regapsp",
                    "",
                    "local M = {}",
                    "",
                    "M.event = \"\"",
                    "M.pattern = \"\"",
                    "",
                    "function M.cond_func()",
                    "    return false",
                    "end",
                    "",
                    "function M.setup()",
                    "end",
                    "",
                    "return M",
                }
            end,
        },
        ["init snip"] = {
            args = { { "file-type" }, },
            content = function(file_type)
                return {
                    { "local snip_filetype = \"", file_type, "\"" },
                    "local s = require \"user.config.snippet.utils\"",
                    "local makers = s.snippet_makers(snip_filetype)",
                    "-- local sp = makers.sp",
                    "-- local asp = makers.asp",
                    "-- local psp = makers.psp",
                    "-- local apsp = makers.apsp",
                    "",
                    "-- local condsp = makers.condsp",
                    "-- local condasp = makers.condasp",
                    "-- local condpsp = makers.condpsp",
                    "-- local condapsp = makers.condapsp",
                    "",
                    "-- local regsp = makers.regsp",
                    "-- local regasp = makers.regasp",
                    "-- local regpsp = makers.regpsp",
                    "-- local regapsp = makers.regapsp",
                }
            end,
        },
    })
end

return M
