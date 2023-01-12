local M = {}

M.PATH_SEP = vim.env.PLATFORM_MARK == "windows" and "\\" or "/"

-- concatenate multiple path component into one.
---@param path string
---@param ... string
---@return string
function M.path_join(path, ...)
    local others = { ... }
    if #others == 0 then return path end

    local sep_size = #M.PATH_SEP
    local size = #path

    for _, other in ipairs(others) do
        local o = tostring(other)
        local o_size = #o
        if path:sub(size) ~= M.PATH_SEP and o:sub(1) ~= M.PATH_SEP then
            path = path .. M.PATH_SEP .. o
            size = size + sep_size + o_size
        else
            path = path .. o
            size = size + o_size
        end
    end

    return path
end

---@param path string
---@return string[]
function M.listdir(path)
    local t = {}
    if vim.fn.isdirectory(path) == 0 then return t end

    path = vim.fn.fnameescape(path)
    local patt = path .. (path:sub(#path) ~= "/" and "/*" or "*")

    local items = vim.fn.glob(patt, 1, 1)
    for _, item in ipairs(items) do
        table.insert(t, item)
    end

    return t
end

function M.walkdir(path)
    local t = {}
    local stack = {}
    local target = path
    local is_dir = vim.fn.isdirectory
    while target do
        local items = M.listdir(target)
        for i = 1, #items do
            local item = items[i]

            table.insert(t, item)

            if is_dir(item) == 1 then
                table.insert(stack, item)
            end
        end

        target = table.remove(stack)
    end

    return t
end

return M
