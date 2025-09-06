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
    -- local s = require "user.config.snippet.utils"
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
                { "source-dir", is_optional = true },
            },
            content = function(source_dir_arg)
                if not source_dir_arg then
                    return SCRIPT_INIT
                end

                local file_name = vim.api.nvim_buf_get_name(0)
                local source_dir = vim.fs.joinpath(vim.fs.dirname(file_name), source_dir_arg)
                local files = fs_util.listdir(source_dir)

                local head = {
                    "local delite = require \"delite\"",
                    "local html = require \"html\"",
                    "local atom = require \"html-atom\"",
                    "",
                    "local Node = html.Node",
                    "local NodeType = html.NodeType",
                    "",

                    "---@param toc_filename string",
                    "local function setup_chapter_title(toc_filename)",
                    "end",
                    "",
                    "---@class CommonSetupArgs",
                    "---@field delete_files string[]",
                    "---@field toc_filename string",
                    "---@field pagebreak_before string[]",
                    "",
                    "---@param args CommonSetupArgs",
                    "local function common_handler(args)",
                    "    delite.delete_file_content(doc_node, args.delete_files)",
                    "",
                    "    setup_chapter_title(args.toc_filename)",
                    "    delite.replace_file_content_with_toc(doc_node, args.toc_filename)",
                    "",
                    "    for _, file in ipairs(args.pagebreak_before) do",
                    "        delite.add_pagebreak_before_file(doc_node, file)",
                    "    end",
                    "end",
                    "",
                    "delite.switch_handler(meta.source_filename, {",
                }
                local tail = {
                    "})",
                    "",
                    'delite.render_node(meta.source_filename .. ".html", doc_node)',
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
