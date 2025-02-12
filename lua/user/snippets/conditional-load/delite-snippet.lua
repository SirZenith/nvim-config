local M = {}

M.event = "BufRead"
M.pattern = "preprocess.lua"
M.cond_func = nil

local SCRIPT_INIT = [[
local delite = require "delite"
-- local html = require "html"
-- local atom = require "html-atom"

delite.switch_handler(meta.source_filename, {
    _ = fnil,
})

return doc_node
]]

function M.setup()
    local cmd_snip = require "cmd-snippet"

    local fs_util = require "user.util.fs"

    local snip_filetype = "lua"
    -- local s = require("snippet-loader.utils")
    -- local makers = s.snippet_makers(snip_filetype)
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

    cmd_snip.register(snip_filetype, {
        ["init script"] = {
            args = {
                { "source", is_optional = true },
            },
            content = function(source)
                if not source then
                    return SCRIPT_INIT
                end

                local file_name = vim.api.nvim_buf_get_name(0)
                local source_dir = vim.fs.joinpath(vim.fs.dirname(file_name), source)
                local files = fs_util.listdir(source_dir)

                local head = {
                    "local delite = require \"delite \"",
                    "-- local html = require \"html\"",
                    "-- local atom = require \"html-atom \"",
                    "",
                    "delite.switch_handler(meta.source_filename, {",
                }
                local tail = {
                    "})",
                    "",
                    "return doc_node",
                }

                local entries = {}
                for _, file in ipairs(files) do
                    local basename = vim.fs.basename(file)
                    table.insert(entries, ("    [\"%s\"] = fnil,"):format(basename))
                end

                local result = {}
                vim.list_extend(result, head)
                vim.list_extend(result, entries)
                vim.list_extend(result, tail)

                return result
            end,
        }
    })
end

return M
