local M = {}

---@type integer
M.log_level = vim.log.levels.WARN

---@param level integer
---@param ... any
function M.log(level, ...)
    if level < M.log_level then return end

    local msg = { ... }
    for i = 1, #msg do
        local value = msg[i]
        msg[i] = type(value) == "string" and value or vim.inspect(value)
    end
    vim.notify(table.concat(msg, " "), level)
end

---@param ... any
function M.trace(...)
    M.log(vim.log.levels.TRACE, ...)
end

---@param ... any
function M.debug(...)
    M.log(vim.log.levels.DEBUG, ...)
end

---@param ... any
function M.info(...)
    M.log(vim.log.levels.INFO, ...)
end

---@param ... any
function M.warn(...)
    M.log(vim.log.levels.WARN, ...)
end

---@param ... any
function M.error(...)
    M.log(vim.log.levels.ERROR, ...)
end

return M
