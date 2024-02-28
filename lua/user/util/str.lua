local M = {}

---@param s string
---@param prefix string
function M.starts_with(s, prefix)
    local l_suf = #prefix
    local l_s = #s
    if l_s < l_suf then
        return false
    end

    return string.sub(s, 1, l_suf) == prefix
end

---@param s string
---@param suffix string
function M.ends_with(s, suffix)
    local l_s = #s
    local l_suf = #suffix
    if l_s < l_suf then
        return false
    end

    return string.sub(s, l_s - l_suf + 1) == suffix
end

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

-- Change fist character of string to upper case
---@param str string
---@return string
function M.first_char_upper(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

return M
