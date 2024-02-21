---@alias user.util.TSNodeHandlerMap table<string, fun(visit_func: user.util.TSNodeVisitFunc, context: user.util.TSNodeHandlerContext, node: TSNode): any>

---@class user.util.TSNodeHandlerContext
---@field handler_map user.util.TSNodeHandlerMap
---@field root TSNode
---@field src string | number
---@field visited_type_set? table<string, boolean>

---@alias user.util.TSNodeVisitFunc fun(context: user.util.TSNodeHandlerContext, node: TSNode): any
