local M = {}

---@return fun(): integer index_generator
function M.new_jump_index()
    local index = 0
    return function()
        index = index + 1
        return index
    end
end

---@param index integer
---@param convertor fun(input: string): string
function M.dynamic_conversion(index, convertor)
    local s = require "user.config.snippet.utils"

    return s.f(function(args)
        local input = args[1][1]
        return convertor(input)
    end, { index })
end

return M
