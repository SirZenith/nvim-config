local PATH_SEP = vim.fn.has("WIN32") == 1 and "\\" or "/"

local initialized = false
local user_runtime_path = ""

---@type table<string, boolean>
local user_module_prefix_tbl = {
    ["user."] = true,
    ["user/"] = true,
}

if PATH_SEP ~= "/" then
    user_module_prefix_tbl["user" .. PATH_SEP] = true
end

---@param path string
---@return string
local function path_name_digest(path)
    local name = path

    local len = #name
    local max_len = 45
    if len > max_len then
        name = "..." .. name:sub(len - max_len + 1)
    end

    return name
end

-- byte code loader
local function byte_code_loader(original_modulename)
    local substr = original_modulename:sub(1, 5)
    if not user_module_prefix_tbl[substr] then
        return "\n\tbyte code config loader: not a module under 'user'"
    end

    local modulename = original_modulename:sub(6)
    if vim.endswith(modulename, ".lua") then
        modulename = modulename:sub(1, #modulename - 4) .. ".luac"
    end
    modulename = "user-build/" .. modulename

    local errmsg = { "" }
    local err_template = "byte code config loader: no file '%s'"

    local paths = {
        vim.fs.joinpath(user_runtime_path, modulename .. ".luac"),
        vim.fs.joinpath(user_runtime_path, modulename, "init.luac"),
    }

    modulename = modulename:gsub("%.", PATH_SEP)
    vim.list_extend(paths, {
        vim.fs.joinpath(user_runtime_path, modulename .. ".luac"),
        vim.fs.joinpath(user_runtime_path, modulename, "init.luac"),
    })

    for i = 1, #paths do
        local path = paths[i]
        local file = io.open(path, "rb")
        if file then
            local content = assert(file:read("*a"))
            local chunkname = path_name_digest(path)
            return assert(loadstring(content, chunkname))
        end
        table.insert(errmsg, err_template:format(path))
    end

    return table.concat(errmsg, "\n\t")
end

---@type (fun(modulename: string): string | function)[]
local loaders = {
    -- plugin config loader
    function(modulename)
        local substr = modulename:sub(1, 5)
        if not user_module_prefix_tbl[substr] then
            return "\n\tplugin config loader: not a module under 'user'"
        end

        local errmsg = { "" }
        local err_template = "plugin config loader: no file '%s'"

        local paths = {
            vim.fs.joinpath(user_runtime_path, modulename .. ".lua"),
            vim.fs.joinpath(user_runtime_path, modulename, "init.lua"),
        }

        for i = 1, #paths do
            local path = paths[i]
            local file = io.open(path, "rb")
            if file then
                local content = assert(file:read("*a"))
                local chunkname = path_name_digest(path)
                return assert(loadstring(content, chunkname))
            end
            table.insert(errmsg, err_template:format(path))
        end

        return table.concat(errmsg, "\n\t")
    end,
    -- no dot substituting loader
    function(modulename)
        local errmsg = { "" }
        local err_template = "no dot-sub loader: no file '%s'"

        for path in string.gmatch(package.path, "([^;]+)") do
            local filename = string.gsub(path, "%?", modulename)
            if vim.fn.filereadable(filename) == 1 then
                local file = io.open(filename, "rb")
                if file then
                    local content = assert(file:read("*a"))
                    local chunkname = path_name_digest(filename)
                    return assert(loadstring(content, chunkname))
                end
            end
            table.insert(errmsg, err_template:format(filename))
        end

        return table.concat(errmsg, "\n\t")
    end,
}

---@class user.ModuleLoaderOptions
---@field enable_byte_code? boolean
---@field user_runtime_path string

local M = {}

---@param options user.ModuleLoaderOptions
function M.init(options)
    if initialized then return end

    initialized = true

    -- allow loading modules via absolute path
    package.path = package.path .. ";?"

    user_runtime_path = options.user_runtime_path

    if options.enable_byte_code then
        table.insert(package.loaders, 1, byte_code_loader)
    end

    for _, loader in ipairs(loaders) do
        table.insert(package.loaders, loader)
    end
end

return M
