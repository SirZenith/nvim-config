local M = {}

---@return fun(): integer index_generato
function M.new_jump_index()
    local index = 0
    return function()
        index = index + 1
        return index
    end
end

return M
