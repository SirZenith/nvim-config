local editing_util = require "user.util.editing"
local ts_util = require "user.util.tree_sitter"

local api = vim.api
local ts = vim.treesitter

local M = {}

---@class user.util.tree_sitter.lisp.GetExpressionOpts
---@field force_parent boolean?

-- get_parent_expression_node_for_range finds smallest expresson node that is
-- larger then specified range.
---@param lang string
---@param dataum_type_tbl table<string, boolean>
---@param st_r integer
---@param st_c integer
---@param ed_r integer
---@param ed_c integer
---@param opts? user.util.tree_sitter.lisp.GetExpressionOpts
---@return TSNode?
function M.get_dataum_node_for_range(lang, dataum_type_tbl, st_r, st_c, ed_r, ed_c, opts)
    local parser = vim.treesitter.get_parser(0, lang)
    local tree_list = parser and parser:parse() or nil
    local tree = tree_list and tree_list[1] or nil
    if not tree then return end

    local root = tree:root()
    local node = root:descendant_for_range(st_r, st_c, ed_r, ed_c)
    if not node or node:id() == root:id() then return end

    local force_parent = opts and opts.force_parent or false
    if not force_parent and dataum_type_tbl[node:type()] then
        return node
    end

    return ts_util.get_parent_of_type(node, dataum_type_tbl)
end

---@param lang string
---@param dataum_type_tbl table<string, boolean>
---@param opts? user.util.tree_sitter.lisp.GetExpressionOpts
---@return TSNode?
function M.get_dataum_node_for_selected_range(lang, dataum_type_tbl, opts)
    local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
    if not st_r or not st_c or not ed_r or not ed_c then
        return
    end

    return M.get_dataum_node_for_range(lang, dataum_type_tbl, st_r, st_c, ed_r, ed_c, opts)
end

---@param node TSNode
---@param symbol_type_tbl table<string, boolean>
function M.del_wrapping_func_call(node, symbol_type_tbl)
    local child_cnt = node:named_child_count()
    if child_cnt <= 0 then return end

    local children = node:named_children()

    local first_child = children[1] --[[@as TSNode]]
    if not symbol_type_tbl[first_child:type()] then
        vim.notify("Current expression is not a function call", vim.log.levels.INFO)
        return
    end

    local st_r, st_c, ed_r, ed_c = ts.get_node_range(node)

    local second_child = children[2]
    local last_child = children[child_cnt]
    if second_child and last_child then
        local content_st_r, content_st_c = ts.get_node_range(second_child)
        local _, _, content_ed_r, content_ed_c = ts.get_node_range(last_child)

        local lines = api.nvim_buf_get_text(0, content_st_r, content_st_c, content_ed_r, content_ed_c, {})
        api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, lines)
    else
        api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, {})
    end
end

-- add_list_sibling_after adds new list sibling after current dataum node
---@param node TSNode
function M.add_list_sibling_after(node)
    local _, _, ed_r, ed_c = node:range()
    api.nvim_win_set_cursor(0, { ed_r + 1, ed_c - 1 })

    vim.cmd [[execute "normal! \<esc>\<esc>"]]
    api.nvim_put({ " ()" }, "c", true, false)
    api.nvim_win_set_cursor(0, { ed_r + 1, ed_c + 2 })
    vim.cmd [[startinsert]]
end

-- get_new_chlid_indent_level finds indent level counted in space for new child
-- node of a dataum node.
---@param node TSNode
---@param dataum_type_tbl table<string, boolean>
---@param symbol_type_tbl table<string, boolean>
---@return integer indent_level
local function get_new_sibling_indent_level(node, dataum_type_tbl, symbol_type_tbl)
    local _, st_c = node:range()

    local dataum_parent = ts_util.get_parent_of_type(node, dataum_type_tbl)
    if not dataum_parent then
        return st_c
    end

    local _, par_st_c = dataum_parent:range()

    local prev_sibling = node:prev_named_sibling()
    if not prev_sibling and symbol_type_tbl[node:type()] then
        local _, par_st_c = dataum_parent:range()
        return par_st_c + 2
    end

    return st_c
end

-- add_list_sibling_newline adds new list sibling after current dataum on a new
-- line
---@param node TSNode
---@param dataum_type_tbl table<string, boolean>
---@param symbol_type_tbl table<string, boolean>
function M.add_list_sibling_newline(node, dataum_type_tbl, symbol_type_tbl)
    local _, _, ed_r, ed_c = node:range()

    local replace_ed_r, replace_ed_c = ed_r, ed_c

    local indent_level = get_new_sibling_indent_level(node, dataum_type_tbl, symbol_type_tbl)

    local indent_unit = " "
    local indent_str = indent_unit:rep(indent_level)
    local lines = { "", indent_str .. "()" }


    local next_sibling = node:next_named_sibling()
    if next_sibling then
        local sib_st_r, sib_st_c, _, _ = next_sibling:range()
        if sib_st_r == ed_r then
            replace_ed_r, replace_ed_c = sib_st_r, sib_st_c
            table.insert(lines, indent_str)
        end
    end

    api.nvim_buf_set_text(0, ed_r, ed_c, ed_r, replace_ed_c, lines)
    api.nvim_win_set_cursor(0, { ed_r + 2, #indent_str + 1 })
    vim.cmd [[execute "normal! \<esc>\<esc>"]]
    vim.cmd [[startinsert]]
end

return M
