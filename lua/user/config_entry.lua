local fnil = require "user.utils.functional".fnil
local table_utils = require "user.utils.table"

local reserved_key = {
    __reserved = true,
}

---@class ConfigEntry
local ConfigEntry = {
    __root_key = "__root",
    __key_sep = ".",
    __class_name = "ConfigEntry",
    __config_base = {},
    __reserved_keys = reserved_key,
}

ConfigEntry.__key = ConfigEntry.__root_key

---@param base? string
---@param new? string
---@return string
function ConfigEntry:join_key(base, new)
    local key
    if not base or #base == 0 or base == self.__root_key then
        key = new
    elseif not new or #new == 0 then
        key = base
    else
        key = base .. self.__key_sep .. new
    end

    if not key or key == "" then
        error("empty key", 2)
    end
    return key
end

---@param key? string
function ConfigEntry:split_key(key)
    key = key or self.__key
    return vim.split(key, self.__key_sep, { plain = true })
end

-- 将传入的 key 接在自身的 key 之后再进行切割，返回最后一分段以及此分段前所有分段
-- 组成的列表。
---@param key? string
---@return string tail
---@return string[] segments
function ConfigEntry:into_segments(key)
    local complelte_key = key
        and self:join_key(self.__key, key)
        or self.__key

    local segments = self:split_key(complelte_key)

    local tail
    if key then
        tail = segments[#segments]
        segments[#segments] = nil
    end

    return tail, segments
end

---@param key? string|table
---@param initial_value? any
---@return ConfigEntry
function ConfigEntry:new(key, initial_value)
    if type(key) == "table" then
        initial_value = key
        key = nil
    end

    key = key ~= nil and key or self.__root_key

    if type(key) ~= "string" then
        error("key of ConfigEntry must be of string type.", 2)
    end

    if initial_value ~= nil then
        self:_set_value(key, table_utils.deep_copy(initial_value))
    end

    return setmetatable({ __key = key }, self)
end

function ConfigEntry:__index(key)
    local value = getmetatable(self)[key] or rawget(self, key)
    if value ~= nil then
        return value
    end

    local new_key = self:join_key(self.__key, key)
    return ConfigEntry:new(new_key)
end

function ConfigEntry:__newindex(key, value)
    if self.__reserved_keys[key] then
        error("use for " .. key .. " is reserved in ConfigEntry", 2)
    end

    local tail, segments = self:into_segments(key)
    local tbl = self:_get_tbl_by_path(segments)
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

function ConfigEntry:append(value)
    local _, segments = self:into_segments()
    local tbl = self:_get_tbl_by_path(segments)
    if not tbl then
        error("trying to append to a non-table value " .. self.__key)
    end

    tbl[#tbl + 1] = value
end

-- 返回当前条目对应的 config 值的 ipairs 迭代器
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

-- 返回当前条目对应的 config 值的 pairs 迭代器
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

---@return any
function ConfigEntry:value()
    return table_utils.deep_copy(self:_get_value())
end

---@param k? string
---@return any value
function ConfigEntry:_get_value(k)
    if k ~= nil and type(k) ~= "string" then
        error("expected key of string type.", 2)
    end

    local key = self.__key
    if key == self.__root_key then
        return self.__config_base
    end

    local complelte_key = self:join_key(key, k)
    local segments = self:split_key(complelte_key)

    k = segments[#segments]
    segments[#segments] = nil

    local tbl = self.__config_base
    for i = 1, #segments do
        tbl = tbl[segments[i]]

        if type(tbl) ~= "table" then
            error("indexing a non-table config: " .. key, 2)
        elseif tbl == nil then
            break
        end
    end

    if not tbl then
        return nil
    else
        return tbl[k]
    end
end

-- 获取 path 指定的 config 结点，如果路径上结点还不存在，则会在途径时创建新表。
-- 如果路径中出现非 table 类型结点，则返回 nil
---@param path_segments string[]
---@return table? tbl
function ConfigEntry:_get_tbl_by_path(path_segments)
    local tbl = self.__config_base
    for i = 1, #path_segments do
        local seg = path_segments[i]
        local new_tbl = tbl[seg]

        if new_tbl == nil then
            new_tbl = {}
            tbl[seg] = new_tbl
        elseif type(new_tbl) ~= "table" then
            tbl = nil
            break
        end

        tbl = new_tbl
    end

    return tbl
end

-- 将值插入到 config 库中。v 为表时，会将深复制后的结果加入到 config。
---@param k any
---@param v any
function ConfigEntry:_set_value(k, v)
    if type(k) ~= "string" then
        error("key of ConfigEntry must be of string type.", 2)
    end

    if k == self.__root_key then
        local v_type = type(v)
        if v_type ~= "table" then
            error("root key of config can only be updated with a table value. (get " .. v_type .. ")", 2)
        end

        table_utils.update_table(self.__config_base, v)

        return
    end

    local tbl = self:_get_value()
    if not tbl then
        error("trying to set value in a nil config: " .. self.__key, 2)
    end

    local old_value = tbl[k]

    if type(old_value) == "table" and type(v) == "table" then
        table_utils.update_table(old_value, v)
    else
        tbl[k] = table_utils.deep_copy(v)
    end
end

-- -----------------------------------------------------------------------------

for k in pairs(ConfigEntry) do
    reserved_key[k] = true
end

local M = {
    ConfigEntry = ConfigEntry
}

return M
