local M = {}

---@param tbl table
---@return boolean
function M.is_array(tbl)
    local result = true
    local size = #tbl

    for k in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k > size then
            result = false
            break
        end
    end

    return result
end

---@param ... any[][]
function M.remove_duplicates(...)
    local set = {}
    for _, list in ipairs({ ... }) do
        for _, item in ipairs(list) do
            set[item] = true
        end
    end

    local results = {}
    for item in pairs(set) do
        results[#results + 1] = item
    end

    return results
end

return M
