local M = {}

-- Truncate long text and put ellipsis at its end.
---@param text string
---@param max_len number
function M.digest(text, max_len)
    local len = vim.fn.strdisplaywidth(text)
    if len <= max_len then
        return text
    end

    return text:sub(1, max_len - 3) .. "..."
end

return M
