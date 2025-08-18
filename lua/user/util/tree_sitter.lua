local editing_util = require "user.util.editing"
local log_util = require "user.util.log"

local api = vim.api
local ts = vim.treesitter

local M = {}

---@param context user.util.TSNodeHandlerContext
---@param node TSNode
---@return any
function M.visit_node(context, node)
    local type = node:type()

    if context.visited_type_set then
        if context.visited_type_set[type] then
            log_util.warn("repeated visited type: " .. type)
            return
        end
        context.visited_type_set[type] = true
    end

    local handler = context.handler_map[type]
    if not handler then
        log_util.warn("can't find handler for type: " .. type)
        return
    end

    return handler(M.visit_node, context, node)
end

---@param bufnr integer
---@param filetype string
---@param handler_map user.util.TSNodeHandlerMap
---@return any
function M.visit_node_in_buffer(bufnr, filetype, handler_map)
    local parser = ts.get_parser(bufnr, filetype)
    local tree = parser:parse()[1]
    local root = tree:root()

    ---@type user.util.TSNodeHandlerContext
    local context = {
        root = root,
        handler_map = handler_map,
        src = bufnr,
    }

    return M.visit_node(context, root)
end

---@param root TSNode?
---@param get_next fun(node: TSNode): TSNode?
---@param type_str string
---@return TSNode?
local function walk_node_until_type_str(root, get_next, type_str)
    local pointer = root

    while pointer do
        if pointer:type() == type_str then
            break
        end
        pointer = get_next(pointer)
    end

    return pointer
end

---@param root TSNode?
---@param get_next fun(node: TSNode): TSNode?
---@param type_tbl table<string, boolean>
---@return TSNode?
local function walk_node_until_type_tbl(root, get_next, type_tbl)
    local pointer = root

    while pointer do
        local cur_type = pointer:type()
        if type_tbl[cur_type] then
            break
        end
        pointer = get_next(pointer)
    end

    return pointer
end

---@param root TSNode?
---@param get_next fun(node: TSNode): TSNode?
---@param node_type string | table<string, boolean>
---@return TSNode?
local function walk_node_until_type(root, get_next, node_type)
    local type_t = type(node_type)
    if type_t == "table" then
        return walk_node_until_type_tbl(root, get_next, node_type)
    elseif type_t == "string" then
        return walk_node_until_type_str(root, get_next, node_type)
    end
    return nil
end

-- get_parent_of_type find nearest parent of a node with given type.
---@param node TSNode # starting node
---@param node_type string | table<string, boolean>
---@return TSNode? result
function M.get_parent_of_type(node, node_type)
    return walk_node_until_type(node:parent(), node.parent, node_type)
end

-- get_next_sibling_of_type finds next sibling node with given type.
---@param node TSNode
---@param node_type string | table<string, boolean>
---@return TSNode?
function M.get_next_sibling_of_type(node, node_type)
    return walk_node_until_type(node:next_sibling(), node.next_sibling, node_type)
end

-- get_previous_sibling_of_type finds previous sibling with given type.
---@param node TSNode
---@param node_type string | table<string, boolean>
---@return TSNode?
function M.get_previous_sibling_of_type(node, node_type)
    return walk_node_until_type(node:prev_sibling(), node.prev_sibling, node_type)
end

-- get_child_of_type finds first child node with given type.
---@param node TSNode
---@param node_type string | table<string, boolean>
---@return TSNode?
function M.get_child_of_type(node, node_type)
    return walk_node_until_type(node:child(0), node.next_sibling, node_type)
end

-- find_first_containing_node_of_type find first node that contains given range
-- with given type.
---@param root TSNode
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@param node_type string
---@return TSNode?
function M.find_first_containing_child_of_type(root, start_row, start_col, end_row, end_col, node_type)
    local result = nil ---@type TSNode?

    local pointer = root ---@type TSNode?
    while pointer do
        local next_pointer = nil ---@type TSNode?
        for child in pointer:iter_children() do
            if child:named() then
                local rst_row, rst_col, red_row, red_col = child:range()
                if rst_row > start_row or (rst_row == start_row and rst_col > start_col) then
                    break
                end

                if red_row > end_row or (red_row == end_row and end_col >= end_col) then
                    next_pointer = child
                end
            end
        end

        if next_pointer and next_pointer:type() == node_type then
            result = next_pointer
            break
        end

        pointer = next_pointer
    end

    return result
end

-- Find smallest named node with given type from cursor position. If no matching
-- node is found, nil will be returned.
---@param bufnr integer? # target buffer, nil or 0 means current buffer.
---@param lang string? # target parser language, default to filetype of buffer.
---@param node_type string # target type.
---@return TSNode?
function M.buf_get_cursor_node_by_type(bufnr, lang, node_type)
    local cur_node = vim.treesitter.get_node({
        bufnr = bufnr,
        lang = lang,
    })

    local pointer = cur_node
    while pointer do
        if pointer:named() and pointer:type() == node_type then
            break
        end
        pointer = pointer:parent()
    end

    return pointer
end

-- select_node_range set visual selection range to given treesitter node.
---@param node TSNode
function M.select_node_range(node)
    local st_r, st_c, ed_r, ed_c = ts.get_node_range(node)
    editing_util.set_selection_range( st_r + 1, st_c , ed_r + 1, ed_c - 1)
end

return M
