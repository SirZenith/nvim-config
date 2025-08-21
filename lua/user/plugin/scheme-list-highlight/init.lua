local ts_util = require "user.util.tree_sitter"
local scheme_ts_util = require "user.util.tree_sitter.scheme"

local api = vim.api
local create_autocmd = api.nvim_create_autocmd

---@type table<string, boolean>
local target_file_types = {
    scheme = true,
}

local augroup_name = "user.plugin.scheme-list-highlight"
local augroup_id = vim.api.nvim_create_augroup(augroup_name, { clear = true })
local ns_id = api.nvim_create_namespace("user.plugin.scheme_highlight")

---@class user.plugin.scheme-list-highlight.HighlightRange
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer

---@type table<integer, user.plugin.scheme-list-highlight.HighlightRange?>
local highlight_range_tbl = {}

---@param bufnr integer
local function update_highlight_range(bufnr)
    local result = ts_util.buf_get_cursor_node_by_type(bufnr, "scheme", scheme_ts_util.LIST_LIKE_TYPE_TBL)
    if not result then return end

    local st_r, st_c, ed_r, ed_c = result:range()

    local target_range = highlight_range_tbl[bufnr]
    if not target_range then
        target_range = {
            start_row = -1,
            start_col = -1,
            end_row = -1,
            end_col = -1,
        }
        highlight_range_tbl[bufnr] = target_range
    end

    local old_start_row = target_range.start_row
    local old_end_row = target_range.end_row
    if st_r ~= old_start_row
        or st_c ~= target_range.start_col
        or ed_r ~= old_end_row
        or ed_c ~= target_range.end_col
    then
        if old_start_row >= 0 and old_end_row >= 0 then
            api.nvim_buf_clear_namespace(bufnr, ns_id, old_start_row, old_end_row + 1)
        end

        api.nvim_buf_set_extmark(bufnr, ns_id, st_r, st_c, {
            end_row = ed_r,
            end_col = ed_c,
            hl_group = "UserPluginSchemeListRange",
            priority = 100,
        })

        target_range.start_row = st_r
        target_range.start_col = st_c
        target_range.end_row = ed_r
        target_range.end_col = ed_c
    end
end

function setup_buffer_autocmd(bufnr)
    update_highlight_range(bufnr)

    create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged" }, {
        group = augroup_id,
        buffer = bufnr,
        callback = function(args)
            update_highlight_range(args.buf)
        end,
    })
end

create_autocmd("FileType", {
    group = augroup_id,
    callback = function(args)
        if not target_file_types[args.match] then
            return
        end
        setup_buffer_autocmd(args.buf)
    end
})
