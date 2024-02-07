---@alias user.utils.TSNodeHandlerMap table<string, fun(visit_func: user.utils.TSNodeVisitFunc, context: user.utils.TSNodeHandlerContext, node: TSNode): any>

---@class user.utils.TSNodeHandlerContext
---@field handler_map user.utils.TSNodeHandlerMap
---@field root TSNode
---@field src string | number
---@field visited_type_set? table<string, boolean>

---@alias user.utils.TSNodeVisitFunc fun(context: user.utils.TSNodeHandlerContext, node: TSNode): any

