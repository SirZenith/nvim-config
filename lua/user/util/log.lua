local M = {}

---@param level integer
---@param ... any
local function log(level, ...)
    local msg = { ... }
    for i = 1, #msg do
        local value = msg[i]
        msg[i] = type(value) == "string" and value or vim.inspect(value)
    end
    vim.notify(table.concat(msg, " "), level)
end

---@param ... any
function M.trace(...)
    log(vim.log.levels.TRACE, ...)
end

---@param ... any
function M.debug(...)
    log(vim.log.levels.DEBUG, ...)
end

---@param ... any
function M.info(...)
    log(vim.log.levels.INFO, ...)
end

---@param ... any
function M.warn(...)
    log(vim.log.levels.WARN, ...)
end

---@param ... any
function M.error(...)
    log(vim.log.levels.ERROR, ...)
end

return M
