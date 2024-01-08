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

-- ----------------------------------------------------------------------------

local special_camel_word = {
    ui = "UI",
    id = "ID",
}

---@param text string
---@return string
local function capital_fist_letter(text)
    if text == "" then return "" end
    return text:sub(1, 1):upper() .. text:sub(2)
end

---@param text string
---@return string
function M.underscore_to_camel_case(text)
    local st, buffer = 1, {}

    for i = 1, #text do
        if text:sub(i, i) == "_" then
            local part = text:sub(st, i - 1)
            local special = special_camel_word[part:lower()]
            buffer[#buffer + 1] = special or capital_fist_letter(part)
            st = i + 1
        end
    end

    buffer[#buffer + 1] = capital_fist_letter(text:sub(st, #text))

    return table.concat(buffer)
end

-- ----------------------------------------------------------------------------

-- wrap require in xpcall, print traceback then return nil when failed.
---@param modname string
---@param failed_msg? string
---@return any?
function M.import(modname, failed_msg)
    local ok, result = xpcall(function() return require(modname) end, debug.traceback)

    local module
    if ok then
        module = result
    else
        if not failed_msg then
            vim.notify(result)
        elseif #failed_msg > 0 then
            vim.notify(failed_msg)
        end
    end

    return module
end

-- Wrap the task_func with a new func, which when called tries to import target module
-- andcall task_func with that module.
-- If loading process successed, wrapper function returns true, else returns false.
---@param modname string
---@param task_func fun(m: any)
---@return fun(): boolean
function M.wrap_with_module(modname, task_func)
    return function()
        local module = M.import(modname, "")
        if not module then
            return false
        end

        task_func(module)

        return true
    end
end

-- Try to finalize a single module
---@param module any
function M.finalize_module(module)
    local module_type = type(module)

    local final
    if module_type == "function" then
        final = module
    elseif module_type == "table" then
        final = module.finalize
    end

    if type(final) == "function" then
        xpcall(final, debug.traceback)
    end
end

-- pass in loaded config modules, this function will finalize them in order.
---@param modules any[]
function M.finalize(modules)
    for i = 1, #modules do
        local module = modules[i]
        M.finalize_module(module)
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

---@param args string[]
---@return string | nil err
---@return string? ...
function M.arg_list_check(args, ...)
    local targets = { ... }
    for i, name in ipairs(targets) do
        if not args[i] then
            return ("expecting '%s' at #%d"):format(name, i)
        end
    end

    return nil, unpack(args)
end

-- notify shows notifycation.
---@param msg string
function M.notify(msg)
    local notify = M.import "notify"
    if notify then
        notify(msg)
    else
        print(msg)
    end
end

return M
