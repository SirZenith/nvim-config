local log_util = require "user.utils.log"

local ts = vim.treesitter

local M = {}

---@param context user.utils.TSNodeHandlerContext
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
---@param handler_map user.utils.TSNodeHandlerMap
---@return any
function M.visit_node_in_buffer(bufnr, filetype, handler_map)
    local parser = ts.get_parser(bufnr, filetype)
    local tree = parser:parse()[1]
    local root = tree:root()

    ---@type user.utils.TSNodeHandlerContext
    local context = {
        root = root,
        handler_map = handler_map,
        src = bufnr,
    }

    return M.visit_node(context, root)
end

return M
