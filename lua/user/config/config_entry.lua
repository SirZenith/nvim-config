local util = require "user.util"
local functional_util = require "user.util.functional"
local log_util = require "user.util.log"
local table_util = require "user.util.table"

local fnil = functional_util.fnil

local reserved_key = {
    __key = true,
    __reserved = true,
}

---@class user.config.ConfigEntry
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
    __meta_keys = {
        __copy = true,     -- add value to ConfigEntry by deep copy.
        __default = true,  -- if old field exists, don't update its value
        __override = true, -- update field value even if it alreay exists.
        __append = true,   -- append list content into config entry
        __replace = true,  -- replace old field by new vlaue directly instead of updating it.
    },
}

-- ----------------------------------------------------------------------------

-- Try to join two key into one, both parameters can be nil at the same time,
-- but can't both be empty string.
---@param base? string
---@param new? string
---@return string?
function ConfigEntry:_join_key(base, new)
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
function ConfigEntry:_split_key(key)
    key = key or self.__key
    return vim.split(key, self.__key_sep, { plain = true })
end

-- Returns list of segments of key path binded with current ConfigEntry object.
-- If extra key is passed, all segments in extra key will be appended to that list.
---@param key? string
---@return string[] segments
function ConfigEntry:_get_key_segments(key)
    local complelte_key = key
        and self:_join_key(self.__key, key)
        or self.__key

    if complelte_key then
        return self:_split_key(complelte_key)
    else
        return {}
    end
end

-- Split a key into its last segment and the remaining part.
---@param key string
---@return string? parent
---@return string child
function ConfigEntry:_split_parent(key)
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

-- ----------------------------------------------------------------------------

-- Remove reserved keys from input value, return modified value.
---@param value any
---@return any
function ConfigEntry:_remove_reserved_keys(value)
    if type(value) ~= "table" then
        return
    end

    for k in pairs(self.__meta_keys) do
        value[k] = nil
    end

    return value
end

-- Specialized version deep copy. Will remove all meta keys from result after
-- copying.
---@param value any
function ConfigEntry:_deep_copy(value)
    value = vim.deepcopy(value)
    self:_remove_reserved_keys(value)
    return value
end

-- Process input value before updating config entry.
---@param value any
function ConfigEntry:_process_new_value(value)
    if type(value) ~= "table" then
        return value
    end

    if not value.__copy then
        return self:_remove_reserved_keys(value)
    end

    return self:_deep_copy(value)
end

-- If `k` is nil, return config of current entry, else get child in current entry.
---@param k? string # a singele-segment key.
---@return any value
function ConfigEntry:_get_value(k)
    if k ~= nil and type(k) ~= "string" then
        error("expected key of string type.", 2)
    end

    local segments = self:_get_key_segments(k)
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
        parent, tail = self:_split_parent(k)
    end

    local tbl = self:_get_value(parent)
    if type(tbl) ~= "table" then
        error("trying to insert config into non-table config: " .. self.__key, 2)
    end

    local old_value = tail == nil and tbl or tbl[tail]

    if type(old_value) == "table" and type(v) == "table" then
        self:_update_table_value(old_value, v)
    elseif tail == nil then
        error("trying to update config with non-table value", 2)
    else
        tbl[tail] = vim.deepcopy(v)
    end
end

---@param dst table
---@param src table
---@param is_override? boolean
---@return boolean ok
function ConfigEntry:_update_table_value(dst, src, is_override)
    is_override = src.__override or is_override or false

    local ok = true

    if src.__append then
        for i = 1, #src do
            dst[#dst + 1] = src[i]
        end
    else
        for k, v in pairs(src) do
            if ConfigEntry.__meta_keys[k] then
                goto continue
            end

            if ConfigEntry.__reserved_keys[k] then
                log_util.warn("'", k, "' is reserved in ConfigEntry")
                ok = false
                goto continue
            end

            local old_value = dst[k]

            if old_value == nil then
                dst[k] = v
                goto continue
            end

            if type(old_value) == "table" then
                self:_update_table_value(old_value, v, is_override)
                goto continue
            end

            if is_override then
                dst[k] = v
            end

            ::continue::
        end
    end

    return ok
end

-- Query config node specified by key segments.
-- Returns nil if segmented path points to nothing or non-table value.
---@param segments string[]
---@return {[string]: any}? tbl
function ConfigEntry:_get_tbl_by_segments(segments)
    local tbl = self.__config_base

    local ok = true
    for i = 1, #segments do
        local seg = segments[i]
        local next_tbl = tbl[seg]

        if type(next_tbl) ~= "table" then
            ok = false
            break
        end

        tbl = next_tbl
    end

    return ok and tbl or nil
end

-- ----------------------------------------------------------------------------

---@param key? string | table
---@param initial_value? any
---@return user.config.ConfigEntry
function ConfigEntry:new(key, initial_value)
    if type(key) == "table" then
        initial_value = key
        key = nil
    elseif key ~= nil and type(key) ~= "string" then
        error("key of ConfigEntry must be string.", 2)
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

    local new_key = self:_join_key(self.__key, key)
    return ConfigEntry:new(new_key)
end

-- Update or insert config value.
-- New key is only allowed when its value is table, and __default is set
-- to ture in that table.
function ConfigEntry:__newindex(key, value)
    if type(key) ~= "string" then
        log_util.error("ConfigEntry key must be string:", key)
        return
    end

    local target = self:_join_key(self.__key, key)

    if ConfigEntry.__reserved_keys[key] then
        log_util.error("'", key, "' is reserved in ConfigEntry:", target)
        return
    end

    local segments = self:_get_key_segments(key)
    local tail = table.remove(segments)
    local tbl = self:_get_tbl_by_segments(segments)
    if not tbl then
        log_util.error("writing to an invalid ConfigEntry:", target)
        return
    end

    local value_t = type(value)
    if value_t ~= "table" then
        log_util.error(
            "while updating:", target,
            "\n    updating config entry with plain value is not allowed"
        )
        return
    end

    -- Updating field with table value
    local old_value = tbl[tail]

    if old_value == nil then
        -- Inserting new field
        local allow_new_value = value.__default or value.__override or false

        if allow_new_value then
            tbl[tail] = self:_process_new_value(value)
        else
            log_util.error("config entry insertion blocked:", target)
        end
    elseif type(old_value) == "table" then
        -- Updating table field
        local is_replace = value.__replace

        if is_replace then
            tbl[tail] = self:_process_new_value(value)
        else
            local ok = self:_update_table_value(old_value, value)
            if not ok then
                log_util.error("error occured while updating:", target)
            end
        end
    else
        -- Field exists, but its value is not a table
        local is_override = value.__override or false

        if is_override then
            tbl[tail] = self:_process_new_value(value)
        end
    end
end

function ConfigEntry:__tostring()
    return vim.inspect(self:_get_value())
end

---@generic T : user.config.ConfigEntry
---@param self T
---@return T
function ConfigEntry.__call(self)
    return self:value()
end

---@generic T : user.config.ConfigEntry
---@param self T
---@return T
function ConfigEntry.value(self)
    return vim.deepcopy(self:_get_value())
end

-- Delete current config entry from config table.
function ConfigEntry:delete()
    local segments = self:_get_key_segments()
    local tail = table.remove(segments)
    if not tail then
        return
    end

    local tbl = self.__config_base
    for i = 1, #segments do
        tbl = tbl[segments[i]]

        if type(tbl) ~= "table" then
            error("trying to delete from a non-table config: " .. tostring(self.__key), 2)
        elseif tbl == nil then
            break
        end
    end

    if not tbl then
        return
    end

    tbl[tail] = nil
end

-- Call consumer function with value of current entry. Entry will be deleted
-- after invokation.
---@param consume fun(value: any): ...
---@return any ...
function ConfigEntry:with(consume)
    local value = self:_get_value()
    self:delete()

    if value == nil then
        log_util.warn("no value found in context invokation:", self.__key)
        return
    end
    return consume(value)
end

-- Return a function. When called, `with` method of current entry is invoked
-- with given consumer function.
---@param consume fun(value: any)
---@return fun(): ...
function ConfigEntry:with_wrap(consume)
    return function() return self:with(consume) end
end

-- Assuming current config entry is a list, append a new element to its end.
function ConfigEntry:append(value)
    local segments = self:_get_key_segments()
    local tbl = self:_get_tbl_by_segments(segments)
    if not tbl then
        error("trying to append to a non-table value " .. self.__key)
    end

    tbl[#tbl + 1] = value
end

-- Assuming current config entry is a list, prepend a new element to its beginning.
function ConfigEntry:prepend(value)
    local segments = self:_get_key_segments()
    local tbl = self:_get_tbl_by_segments(segments)
    if not tbl then
        error("trying to append to a non-table value " .. self.__key)
    end

    table.insert(tbl, 1, value)
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

-- ----------------------------------------------------------------------------

for k in pairs(ConfigEntry) do
    reserved_key[k] = true
end

local M = {
    ConfigEntry = ConfigEntry
}

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
    parent_class = parent_class or "user.config.ConfigEntry"
    if table_util.is_array(tbl) then
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
            table.insert(env.buffer, "---@field " .. key .. "? " .. type(value))
        else
            local name = class_name .. util.underscore_to_camel_case(key)
            table.insert(env.buffer, "---@field " .. key .. "? " .. name)
            table.insert(env.pending, { name = name, value = value })
        end
    end

    table.insert(env.buffer, "")
end

---@param config_entry user.config.ConfigEntry
---@return string
local function dump_signature(config_entry)
    ---@class DumpEnv
    local env = {
        buffer = { "---@meta", "" },
        pending = {},
    }

    local target = { name = "UserConfig", value = config_entry(), parent_class = "" }
    while target do
        _dump_config_class(env, target.name, target.value, target.parent_class)
        target = table.remove(env.pending, 1)
    end

    return table.concat(env.buffer, "\n")
end

---@param config_entry user.config.ConfigEntry
---@param path string # path to output meta file
function M.dump_signature(config_entry, path)
    local loop = vim.loop

    local permission = 480 -- 0o740
    loop.fs_open(path, "w+", permission, function(open_err, fd)
        if open_err or not fd then
            log_util.info(open_err or "failed to open config meta file")
            return
        end

        local metadata = dump_signature(config_entry)
        loop.fs_write(fd, metadata, function(write_err)
            if write_err then
                log_util.info(write_err)
                return
            end

            loop.fs_close(fd)
        end)
    end)
end

return M
