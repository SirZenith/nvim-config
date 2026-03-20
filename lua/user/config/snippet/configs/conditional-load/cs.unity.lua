local str_util = require "user.util.str"
local fs_util = require "user.util.fs"
local snippet_util = require "user.util.snippet"

local snip_filetype = "cs"
local s = require "user.config.snippet.utils"
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

-- Generate panel name and class name by file name.
---@param index_gen fun(): integer # index generator
local function get_class_name_from_file_name(index_gen)
    local file_name = vim.api.nvim_buf_get_name(0)
    file_name = fs_util.remove_ext(file_name)
    file_name = vim.fs.basename(file_name) or ""
    return file_name
end

local M = {}

M.event = "FileType"
M.pattern = "cs"

function M.cond_func()
    return true
end

function M.setup()
    local cmd_snip = require "cmd-snippet"

    cmd_snip.register(snip_filetype, {
        ["new monobehaviour"] = {
            content = function()
                local index = snippet_util.new_jump_index()
                local class_name = get_class_name_from_file_name(index)

                return {
                    "using UnityEngine;",
                    "",
                    { "public class ", class_name, " : MonoBehaviour" },
                    "{",
                    "}",
                }
            end,
        },
    })
end

return M
