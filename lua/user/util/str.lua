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
    if str == "" then return str end
    return str:sub(1, 1):upper() .. str:sub(2)
end

local special_camel_word = {
    ui = "UI",
    id = "ID",
}

---@param text string
---@return string
function M.underscore_to_camel_case(text)
    local st, buffer = 1, {}

    for i = 1, #text do
        if text:sub(i, i) == "_" then
            local part = text:sub(st, i - 1)
            local special = special_camel_word[part:lower()]
            buffer[#buffer + 1] = special or M.first_char_upper(part)
            st = i + 1
        end
    end

    buffer[#buffer + 1] = M.first_char_upper(text:sub(st, #text))

    return table.concat(buffer)
end

return M
