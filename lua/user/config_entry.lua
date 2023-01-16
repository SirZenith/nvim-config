local fnil = require "user.utils.functional".fnil
local table_utils = require "user.utils.table"

local reserved_key = {
    __key = true,
    __reserved = true,
}

---@class ConfigEntry
--
---@field __key_sep string
---@field __config_base {[string]: any}
---@field __reserved_keys {[string]: boolean}
--
---@field __key string
local ConfigEntry = {
    __key_sep = ".",
    __config_base = {},
    __reserved_keys = reserved_key,
}

-- -----------------------------------------------------------------------------

-- Try to join two key into one, both parameters can be nil at the same time,
-- but can't both be empty string.
---@param base? string
---@param new? string
---@return string?
function ConfigEntry:join_key(base, new)
    local key
    if not base or #base == 0 then
        key = new
    elseif not new or #new == 0 then
        key = base
    else
        key = base .. self.__key_sep .. new
    end

    if key == "" then
        error("empty string key", 2)
    end

    return key
end

---@param key? string
function ConfigEntry:split_key(key)
    key = key or self.__key
    return vim.split(key, self.__key_sep, { plain = true })
end

-- return list of segments in current key.
-- If extra key is passed, all segments in extra key will be appended to that list.
---@param key? string
---@return string[] segments
function ConfigEntry:get_key_segments(key)
    local complelte_key = key
        and self:join_key(self.__key, key)
        or self.__key

    if complelte_key then
        return self:split_key(complelte_key)
    else
        return {}
    end
end

---@param key string
---@return string? parent
---@return string child
function ConfigEntry:split_parent(key)
    local len = #key

    local index
    for i = len, 1, -1 do
        if key:sub(i, i) == self.__key_sep then
            index = i
            break
        end
    end

    if not index then
        return nil, key
    elseif index == 1 or index == len then
        error("illegal key: " .. key)
    else
        return key:sub(1, index - 1), key:sub(index + 1)
    end
end

-- -----------------------------------------------------------------------------

-- If `k` is nil, return config of current entry, else get child in current entry.
---@param k? string # a singele-segment key.
---@return any value
function ConfigEntry:_get_value(k)
    if k ~= nil and type(k) ~= "string" then
        error("expected key of string type.", 2)
    end

    local segments = self:get_key_segments(k)
    local tail = table.remove(segments)

    local tbl = self.__config_base
    for i = 1, #segments do
        tbl = tbl[segments[i]]

        if type(tbl) ~= "table" then
            error("indexing a non-table config: " .. tostring(self.__key), 2)
        elseif tbl == nil then
            break
        end
    end

    if not tbl then
        return nil
    elseif not tail then
        return tbl
    else
        return tbl[tail]
    end
end

-- Inserting a value into internal config. Current entry must be table value.
-- If `k` is not nil, a deep copy of `v` will be inserted into current entry,
-- else `v` should be table, current entry will be updated using `v`.
---@param k? string
---@param v any
function ConfigEntry:_set_value(k, v)
    if k ~= nil and type(k) ~= "string" then
        error("key of ConfigEntry must be of string type", 2)
    end

    local parent, tail
    if k then
        parent, tail = self:split_parent(k)
    end

    local tbl = self:_get_value(parent)
    if type(tbl) ~= "table" then
        error("trying to insert config into non-table config: " .. self.__key, 2)
    end

    local old_value = tail == nil and tbl or tbl[tail]

    if type(old_value) == "table" and type(v) == "table" then
        table_utils.update_table(old_value, v)
    elseif tail == nil then
        error("trying to update config with non-table value", 2)
    else
        tbl[tail] = table_utils.deep_copy(v)
    end
end

-- query config node specified by key segments. During process, non-exesits node
-- will be created.
-- If key path runs into a non-table node, this function returns nil.
---@param segments string[]
---@return {[string]: any}? tbl
function ConfigEntry:_get_tbl_by_segments(segments)
    local tbl = self.__config_base

    local ok = true
    for i = 1, #segments do
        local seg = segments[i]
        local next_tbl = tbl[seg]

        if next_tbl == nil then
            next_tbl = {}
            tbl[seg] = next_tbl
        elseif type(next_tbl) ~= "table" then
            ok = false
            break
        end

        tbl = next_tbl
    end

    return ok and tbl or nil
end

-- -----------------------------------------------------------------------------

---@param key? string|table
---@param initial_value? any
---@return ConfigEntry
function ConfigEntry:new(key, initial_value)
    if type(key) == "table" then
        initial_value = key
        key = nil
    elseif key ~= nil and type(key) ~= "string" then
        error("key of ConfigEntry must be of string type.", 2)
    end

    if initial_value ~= nil then
        self:_set_value(key, initial_value)
    end

    return setmetatable({ __key = key }, self)
end

function ConfigEntry:__index(key)
    if key == nil then
        error("trying to index config with nil key", 2)
    end

    local value = ConfigEntry[key] or rawget(self, key)
    if ConfigEntry.__reserved_keys[key] or value ~= nil then
        return value
    end

    local new_key = self:join_key(self.__key, key)
    return ConfigEntry:new(new_key)
end

function ConfigEntry:__newindex(key, value)
    if type(key) ~= "string" then
        error("key of ConfigEntry must be of string type.", 2)
    elseif ConfigEntry.__reserved_keys[key] then
        error("use for " .. key .. " is reserved in ConfigEntry", 2)
    end

    local segments = self:get_key_segments(key)
    local tail = table.remove(segments)
    local tbl = self:_get_tbl_by_segments(segments)
    if not tbl then
        error("trying to write to a non-table config: " .. self.__key, 2)
    end

    local old_value = tbl[tail]
    if type(old_value) == "table" and type(value) == "table" then
        table_utils.update_table(old_value, value)
    else
        tbl[tail] = table_utils.deep_copy(value)
    end
end

function ConfigEntry:__tostring()
    return vim.inspect(self:_get_value())
end

function ConfigEntry:__call()
    return self:value()
end

---@return any
function ConfigEntry:value()
    return table_utils.deep_copy(self:_get_value())
end

function ConfigEntry:append(value)
    local segments = self:get_key_segments()
    table.remove(segments)
    local tbl = self:_get_tbl_by_segments(segments)
    if not tbl then
        error("trying to append to a non-table value " .. self.__key)
    end

    tbl[#tbl + 1] = value
end

-- return ipairs iterator of config in current entry for `for` loop.
---@return fun(state: any, var: any): any func
---@return any state
---@return any init_var
function ConfigEntry:ipairs()
    local value = self:value()
    if type(value) ~= "table" then
        return fnil
    elseif value[1] == nil then
        return fnil
    end

    return ipairs(value)
end

-- return pairs iterator of config in current entry for `for` loop.
---@return fun(state: any, var: any): any func
---@return any state
---@return any init_var
function ConfigEntry:pairs()
    local value = self:value()
    if type(value) ~= "table" then
        return fnil
    elseif next(value) == nil then
        return fnil
    end

    return pairs(value)
end

-- -----------------------------------------------------------------------------

for k in pairs(ConfigEntry) do
    reserved_key[k] = true
end

local M = {
    ConfigEntry = ConfigEntry
}

return M
