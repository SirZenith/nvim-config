require "user.utils"

local M = {}

M.PATH_SEP = vim.fn.has("WIN32") == 1 and "\\" or "/"

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

-- Convert a path to its normalized absolute form.
---@return string
function M.to_abs(path)
    if path == "" then return path end

    path = vim.fs.normalize(path)
    local parts = vim.split(path, "/")
    if parts[1] == "." then
        local cwd = vim.fn.getcwd()
        cwd = vim.fs.normalize(cwd)
        parts = vim.list_extend(vim.split(cwd, "/"), parts)
    end

    local delta = 0
    for i = 1, #parts do
        local part = parts[i]
        if part == "." then
            delta = delta + 1
            parts[i] = nil
        elseif part == ".." then
            delta = delta + 2
            parts[i] = nil
        elseif delta > 0 then
            local target = i - delta
            if target < 1 then
                target = 1
            end

            parts[i] = nil
            parts[target] = part
        end
    end

    return table.concat(parts, "/")
end

-- check if `path` is a sub directory of `other`.
---@param path string
---@param other string
---@return boolean
function M.is_subdir_of(path, other)
    path = M.to_abs(path)
    other = M.to_abs(other)
    return other == path:sub(1, #other)
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

-- Remove duplication from path list. Order of original list is not preserved.
---@param list string[]
---@return string[]
function M.path_list_dedup(list)
    local paths = {}
    for i = 1, #list do
        paths[i] = vim.fs.normalize(list[i])
    end

    table.sort(paths, function(a, b)
        return a:len() < b:len()
    end)

    local dir_set = {}
    local delta = 0
    for i = 1, #paths do
        local path = paths[i]
        local abs_path = M.to_abs(path)
        local marked = dir_set[abs_path]

        if not marked then
            for dir in vim.fs.parents(abs_path) do
                if dir_set[dir] then
                    marked = true
                    break
                end
            end
        end

        if marked then
            delta = delta + 1
            paths[i] = nil
        elseif delta > 0 then
            dir_set[abs_path] = true
            paths[i] = nil
            paths[i - delta] = path
        else
            dir_set[abs_path] = true
        end
    end

    return paths
end

-- Remove extension name from path
---@param path string
function M.remove_ext(path)
    local index = 0
    for i = #path, 0, -1 do
        local char = path:sub(i, i)

        if char == "/" or char == "\\" then
            break
        elseif char == "." then
            local next_char = path:sub(i - 1, i - 1)

            if next_char ~= ""
                and next_char ~= "/"
                and next_char ~= "\\"
            then
                index = i - 1
            end

            break
        end
    end

    if index > 0 then
        path = path:sub(1, index)
    end

    return path
end

return M
