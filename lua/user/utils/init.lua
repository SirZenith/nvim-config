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

---@class PendingTarget
---@field name string
---@field value table

---@class DumpEnv
---@field buffer string[] # dump result line buffer
---@field cur_path string[]
---@field pending PendingTarget[]

---@param env DumpEnv
---@param class_name string
---@param tbl any
---@param parent_class? string
local function _dump_config_class(env, class_name, tbl, parent_class)
    local table_utils = require "user.utils.table"

    parent_class = parent_class or "ConfigEntry"
    if table_utils.is_array(tbl) then
        ---@type string
        local element_type = tbl[1] and type(tbl[1]) or "any"
        table.insert(env.buffer, "-- underlaying: " .. element_type .. "[]")
    end

    local class_line = "---@class " .. class_name
    if parent_class ~= "" then
        class_line = class_line .. " : " .. parent_class
    end
    table.insert(env.buffer, class_line)

    for key, value in pairs(tbl) do
        if type(key) == "number" then
            -- pass
        elseif type(value) ~= "table" then
            table.insert(env.buffer, "---@field " .. key .. " " .. type(value))
        else
            local name = class_name .. M.underscore_to_camel_case(key)
            table.insert(env.buffer, "---@field " .. key .. " " .. name)
            table.insert(env.pending, { name = name, value = value })
        end
    end

    table.insert(env.buffer, "")
end

---@return string
local function dump_signature()
    local user = require "user"

    ---@class DumpEnv
    local env = {
        buffer = { "---@meta", ""},
        pending = {},
    }

    local target = { name = "UserConfig", value = user(), parent_class = "" }
    while target do
        _dump_config_class(env, target.name, target.value, target.parent_class)
        target = table.remove(env.pending, 1)
    end

    return table.concat(env.buffer, "\n")
end

function M.dump_signature_metafile()
    local user = require "user"
    local fs = require "user.utils.fs"

    local filepath = fs.path_join(user.env.CONFIG_HOME(), "user", "meta", "user_config.lua")

    local file, err = io.open(filepath, "w")
    if not file then
        vim.notify(err or "")
        return
    end

    local metadata = dump_signature()
    file:write(metadata)
    file:close()
end

return M
