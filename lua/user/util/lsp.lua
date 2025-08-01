local M = {}

---@param config table
---@param dot_path string
---@param value any
function M.upsert_config_entry(config, dot_path, value)
    local segments = vim.split(dot_path, ".", { plain = true })
    local tail = table.remove(segments)

    local walker = config
    for _, seg in ipairs(segments) do
        local next_step = walker[seg]
        if not next_step then
            next_step = {}
            walker[seg] = next_step
        end
        walker = next_step
    end

    walker[tail] = value
end

---@param config table
---@param dot_path string
---@param value any
function M.append_config_entry(config, dot_path, value)
    if value == nil then
        return
    end

    local segments = vim.split(dot_path, ".", { plain = true })
    local tail = table.remove(segments)

    local walker = config
    for _, seg in ipairs(segments) do
        local next_step = walker[seg]
        if not next_step then
            next_step = {}
            walker[seg] = next_step
        end
        walker = next_step
    end

    local list = walker[tail]
    if not list then
        list = {}
        walker[tail] = list
    end

    list[#list + 1] = value
end

return M
