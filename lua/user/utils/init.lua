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

-- ----------------------------------------------------------------------------

function M.dump_signature_metafile()
    local user = require "user"
    local fs = require "user.utils.fs"

    local filepath = fs.path_join(user.env.CONFIG_HOME(), "user", "meta", "user_config.lua")

    local file, err = io.open(filepath, "w")
    if not file then
        vim.notify(err or "")
        return
    end

    local metadata = user:dump_signature()
    file:write(metadata)
    file:close()
end

return M
