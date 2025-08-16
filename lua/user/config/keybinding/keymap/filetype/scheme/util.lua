local editing_util = require "user.util.editing"
local ts_util = require "user.util.tree_sitter"

local api = vim.api
local ts = vim.treesitter

local M = {}

---@class user.keybinding.scheme.GetExpressionOpts
---@field force_parent boolean?

-- get_parent_expression_node_for_range finds smallest expresson node that is
-- larger then specified range.
---@param st_r integer
---@param st_c integer
---@param ed_r integer
---@param ed_c integer
---@param opts? user.keybinding.scheme.GetExpressionOpts
---@return TSNode?
function M.get_expression_node_for_range(st_r, st_c, ed_r, ed_c, opts)
    local parser = vim.treesitter.get_parser(0, "scheme")
    local tree_list = parser and parser:parse() or nil
    local tree = tree_list and tree_list[1] or nil
    if not tree then return end

    local root = tree:root()
    local node = root:descendant_for_range(st_r, st_c, ed_r, ed_c)
    if not node or node:id() == root:id() then return end

    local target_type = "list"

    local force_parent = opts and opts.force_parent or false
    if not force_parent and node:type() == target_type then
        return node
    end

    return ts_util.get_parent_of_type(node, target_type)
end

---@param opts? user.keybinding.scheme.GetExpressionOpts
---@return TSNode?
function M.get_expression_node_for_selected_range(opts)
    local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
    if not st_r or not st_c or not ed_r or not ed_c then
        return
    end

    return M.get_expression_node_for_range(st_r, st_c, ed_r, ed_c, opts)
end

---@param node TSNode
function M.del_wrapping_func_call(node)
    local child_cnt = node:named_child_count()
    if child_cnt <= 0 then return end

    local children = node:named_children()

    local first_child = children[1] --[[@as TSNode]]
    if first_child:type() ~= "symbol" then
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

return M
