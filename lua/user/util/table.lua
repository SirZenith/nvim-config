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

-- reverse reverses a list in place. Then list gets passed in will be returned.
---@param list any[]
---@return any[]
function M.reverse(list)
    local len = #list
    if #list <= 1 then return list end

    for i = 1, math.floor(len / 2) do
        local temp = list[i]
        local to_index = len - i + 1
        list[i] = list[to_index]
        list[to_index] = temp
    end

    return list
end

return M
