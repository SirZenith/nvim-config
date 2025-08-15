local log_util = require "user.util.log"

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

return M
