local lisp_util = require "user.util.tree_sitter.lisp"

local M = {}

local QUOTED_TYPE_TBL = {
    ["quote"] = true,
    ["quasiquote"] = true,
    ["unquote"] = true,
    ["unquote_splicing"] = true,
}
M.QUOTED_TYPE_TBL = QUOTED_TYPE_TBL

local LIST_LIKE_TYPE_TBL = {
    ["list"] = true,
    ["program"] = true,
}
M.LIST_LIKE_TYPE_TBL = LIST_LIKE_TYPE_TBL

local DATAUM_TYPE_TBL = {
    ["boolean"] = true,
    ["character"] = true,
    ["string"] = true,

    ["number"] = true,
    ["symbol"] = true,

    ["vector"] = true,
    ["byte_vector"] = true,
    ["list"] = true,

    ["quote"] = true,
    ["quasiquote"] = true,
    ["unquote"] = true,
    ["unquote_splicing"] = true,
    ["syntax"] = true,
    ["quasisyntax"] = true,
    ["unsyntax"] = true,
    ["unsyntax_splicing"] = true,

    ["keyword"] = true,
}
M.DATAUM_TYPE_TBL = DATAUM_TYPE_TBL

local SYMBOL_TYPE_TBL = {
    ["symbol"] = true,
}
M.SYMBOL_TYPE_TBL = SYMBOL_TYPE_TBL

-- get_parent_expression_node_for_range finds smallest expresson node that is
-- larger then specified range.
---@param st_r integer
---@param st_c integer
---@param ed_r integer
---@param ed_c integer
---@param opts? user.util.tree_sitter.lisp.GetExpressionOpts
---@return TSNode?
function M.get_dataum_node_for_range(st_r, st_c, ed_r, ed_c, opts)
    return lisp_util.get_dataum_node_for_range("scheme", DATAUM_TYPE_TBL, st_r, st_c, ed_r, ed_c, opts)
end

---@param opts? user.util.tree_sitter.lisp.GetExpressionOpts
---@return TSNode?
function M.get_dataum_node_for_selected_range(opts)
    return lisp_util.get_dataum_node_for_selected_range("scheme", DATAUM_TYPE_TBL, opts)
end

---@param node TSNode
function M.del_wrapping_func_call(node)
    lisp_util.del_wrapping_func_call(SYMBOL_TYPE_TBL, node)
end

-- add_list_sibling_after adds new list sibling after current dataum node
---@param node TSNode
function M.add_list_sibling_after(node)
    lisp_util.add_list_sibling_after(node)
end

-- add_list_sibling_newline adds new list sibling after current dataum on a new
-- line
---@param node TSNode
function M.add_list_sibling_newline(node)
    lisp_util.add_list_sibling_newline(DATAUM_TYPE_TBL, LIST_LIKE_TYPE_TBL, node)
end

return M
