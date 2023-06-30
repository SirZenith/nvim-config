---@param s string
---@param prefix string
function string.starts_with(s, prefix)
    local l_suf = #prefix
    local l_s = #s
    if l_s < l_suf then
        return false
    end

    return string.sub(s, 1, l_suf) == prefix
end

---@param s string
---@param suffix string
function string.ends_with(s, suffix)
    local l_s = #s
    local l_suf = #suffix
    if l_s < l_suf then
        return false
    end

    return string.sub(s, l_s - l_suf + 1) == suffix
end

-- ----------------------------------------------------------------------------

local M = {}

-- wrap require in xpcall, print traceback then return nil when failed.
---@param modname string
function M.import(modname)
    local ok, result = xpcall(function() return require(modname) end, debug.traceback)

    local module
    if ok then
        module = result
    else
        vim.notify(result)
    end

    return module
end

-- pass in loaded config modules, this function will finalize them in order.
---@param modules any[]
function M.finalize(modules)
    for i = 1, #modules do
        local module = modules[i]
        local module_type = type(module)

        local final
        if module_type == "function" then
            final = module
        elseif module_type == "table" then
            final = module.finalize
        end

        if type(final) == "function" then
            final()
        end
    end
end

---@generic T
---@param a T
---@param b T
---@return T
function M.min(a, b)
    if not (a and b) then return nil end
    return a <= b and a or b
end

---@generic T
---@param a T
---@param b T
---@return T
function M.max(a, b)
    if not (a and b) then return nil end
    return a >= b and a or b
end

return M
