local M = {}

M.event = "BufRead"
M.pattern = "preprocess.lua"
M.cond_func = nil

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
        ["handling toc-with-id"] = {
            content = {
                "for node in delite.iter_in_file_matching(doc_node, toc_filename, {",
                "    tag = atom.A,",
                '    attr = "href",',
                "}) do",
                '    local href = node:attr("href") or ""',
                '    local id = href:match(".*#(.+)")',
                "    local title_node = id and doc_node:find { id = id }",
                "",
                "    if title_node then",
                "        title_node:change_tag(atom.H1)",
                "    end",
                "end",
            },
        },

        ["init script"] = {
            args = {
                { "source-dir", is_optional = true },
            },
            content = function(source_dir_arg)
                local head = {
                    "local delite = require \"delite\"",
                    "local html = require \"html\"",
                    "local atom = require \"html-atom\"",
                    "",
                    "local Node = html.Node",
                    "local NodeType = html.NodeType",
                    "",
                    "---@param toc_filename string",
                    "local function default_chapter_handler(toc_filename)",
                    "end",
                    "",
                    "---@param toc_filename string",
                    "local function default_toc_content_handler(toc_filename)",
                    "    delite.replace_file_content_with_toc(doc_node, toc_filename)",
                    "end",
                    "",
                    "---@class CommonSetupArgs",
                    "---@field delete_files string[]",
                    "---@field toc_filename string",
                    "---@field chapter_title_handler? fun(toc_filename: string)",
                    "---@field toc_content_handler? fun(toc_filename: string)",
                    "---@field pagebreak_before string[]",
                    "",
                    "---@param args CommonSetupArgs",
                    "local function common_handler(args)",
                    "    local toc_filename = args.toc_filename",
                    '    if toc_filename ~= "" then',
                    '        if type(args.chapter_title_handler) == "function" then',
                    "            args.chapter_title_handler(toc_filename)",
                    "        else",
                    "            default_chapter_handler(args.toc_filename)",
                    "        end",
                    "",
                    '        if type(args.toc_content_handler) == "function" then',
                    "            args.toc_content_handler(toc_filename)",
                    "        else",
                    "            default_toc_content_handler(toc_filename)",
                    "        end",
                    "    end",
                    "",
                    "    for _, file in ipairs(args.pagebreak_before) do",
                    "        delite.add_pagebreak_before_file(doc_node, file)",
                    "    end",
                    "",
                    "    delite.delete_file_content(doc_node, args.delete_files)",
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

                if source_dir_arg then
                    local file_name = vim.api.nvim_buf_get_name(0)
                    local source_dir = vim.fs.joinpath(vim.fs.dirname(file_name), source_dir_arg)
                    local files = fs_util.listdir(source_dir)

                    for _, file in ipairs(files) do
                        local basename = vim.fs.basename(file)
                        table.insert(entries, ("    [\"%s\"] = fnil,"):format(basename))
                    end
                else
                    table.insert(entries, "    _ = fnil,")
                end

                local result = {}
                vim.list_extend(result, head)
                vim.list_extend(result, entries)
                vim.list_extend(result, tail)

                return result
            end,
        },

        ["new common-handling"] = {
            content = {
                "common_handler {",
                "    delete_files = {},",
                '    toc_filename = "",',
                "    pagebreak_before = {},",
                "}",
            }
        },
    })
end

return M
