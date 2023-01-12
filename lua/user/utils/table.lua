local M = {}

-- 复制传入的值，如果传入值的类型为 table 则进行浅复制，否则将参数原样返回。
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

-- 复制传入的值，如果传入值的类型为 table 则进行深复制，否则将参数原样返回。
---@param src any
---@return any
function M.deep_copy(src)
    if type(src) ~= "table" then return src end

    local tbl = {}
    for k, v in pairs(src) do
        tbl[k] = M.deep_copy(v)
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

-- 使用 src 中的字段更新 dst。
-- src 中的字段如果在 dst 中也存在，则会使用 src 中的值覆盖 dst 中的值；
-- src 中的字段如果在 dst 中不存在，则会向 dst 中添加对应的字段；
-- dst 中存在但 src 中不存在的字段不会改变。
-- 如果需要复制的字段值是 table，则会递归运用上述规则，
-- 若要强制使用 src 中的 table 覆盖 dst 中对应的值，请在 src 的 table 字段中加入
-- `__override = true`。
-- 如果需要以列表形式将 src 中的表字段加入到 dst 对应位置，则可以在 src 字段值
-- 中加入 `__append = true`。
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
