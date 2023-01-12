local M = {}

M.fnil = function() end

---@generic T
---@param list T[]
---@param cond_func fun(i: integer, item: T): boolean
---@return boolean
function M.all(list, cond_func)
    for i = 1, #list do
        if not cond_func(i, list[i]) then return false end
    end
    return true
end

---@generic T
---@param list T[]
---@param cond_func fun(i: integer, item: T): boolean
---@return boolean
function M.any(list, cond_func)
    for i = 1, #list do
        if cond_func(i, list[i]) then return true end
    end
    return false
end

---@generic T
---@param list T[]
---@param cond_func fun(i: integer, item: T): boolean
---@return T[]
function M.filter(list, cond_func)
    local tab = {}
    for i = 1, #list do
        local item = list[i]
        if cond_func(i, item) then tab[#tab + 1] = item end
    end
    return tab
end

return M
