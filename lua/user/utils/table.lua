local M = {}

---@param tbl table
---@return boolean
function M.is_array(tbl)
    local result = true
    local size = #tbl

    for k in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k > size then
            result = false
            break
        end
    end

    return result
end

-- if input value is a table, return its shallow copy, else return the value directly.
---@param src any
---@return any
function M.copy(src)
    if type(src) ~= "table" then return src end

    local tbl = {}
    for k, v in pairs(src) do
        tbl[k] = v
    end

    return tbl
end

-- if input value is a table, return its deep copy, else return the value directly.
---@param src any
---@return any
function M.deep_copy(src)
    if type(src) ~= "table" then return src end

    local tbl = {}
    for k, v in pairs(src) do
        tbl[k] = M.deep_copy(v)
    end

    local mt = getmetatable(src)
    if mt then
        setmetatable(tbl, mt)
    end

    return tbl
end

---@generic T
---@param dst T[]
---@param src T[]
function M.extend_list(dst, src)
    for i = 1, #src do
        table.insert(dst, src[i])
    end
end

-- update fields in dst using value in src.
-- if a filed appears only in src, add this value to dst;
-- if a field appears only in dst, it will be leave untouched;
-- if a field appears both in src and dst:
--     - if field value in src is not a table, override dst's value with src's one;
--     - if field value in dst is not a table, override dst's value with src's one;
--     - when field value in both src and dst are tables, recursively apply all other rules on this field.
-- If you wnat to override dst's field directly with a table in src, you can add
-- `__override = true` into that table value.
-- If you want to append values in a table field in src into dst's one, you can
-- add `__append = true` into that table value.
---@param dst table
---@param src table
function M.update_table(dst, src)
    for k, v in pairs(src) do
        local v_dst = dst[k]
        local v_type = type(v)

        if not v_dst
            or v_type ~= "table"
            or type(v_dst) ~= "table"
        then
            dst[k] = v
        elseif v.__append == true then
            M.extend_list(v_dst, v)
        elseif v.__override == true then
            local new_v = {}
            for key, value in pairs(v) do
                new_v[key] = value
            end
            new_v.__override = nil
            dst[k] = new_v
        else
            M.update_table(v_dst, v)
        end
    end
end

---@param ... any[][]
function M.remove_duplicates(...)
    local set = {}
    for _, list in ipairs({ ... }) do
        for _, item in ipairs(list) do
            set[item] = true
        end
    end

    local results = {}
    for item in pairs(set) do
        results[#results + 1] = item
    end

    return results
end

return M
