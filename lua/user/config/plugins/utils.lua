local M = {}

---@param spec user.plugin.PluginSpec
function M.user_config_init(spec)
    local module = spec.name
    if not module then
        vim.notify("can't find `name` in spec for user config module", vim.log.levels.WARN)
        return
    end

    require(spec.name)
end

---@param module_name string
---@return  user.plugin.PluginSpec?
function M.user_config_spec(module_name)
    local base_config, err = require "user.config"
    if err then
        vim.notify(err, vim.log.levels.WARN)
        return nil
    end

    ---@type user.plugin.PluginSpec
    local spec = {
        name = module_name,
        dir = base_config.env.USER_RUNTIME_PATH,
        config = M.user_config_init,
    }

    local base_module = "user.config.general";
    if module_name ~= base_module then
        spec.dependencies = { base_module }
    end

    return spec
end

function M.turn_on_true_color()
    if vim.fn.has "nvim" then
        vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    end

    if vim.fn.has "termguicolors" then
        vim.o.termguicolors = true
    end
end

function M.after_color_scheme_loaded()
    local user = require "user"
    local colorscheme = user.theme.colorscheme()
    if colorscheme and colorscheme ~= "" then
        vim.cmd("colorscheme " .. colorscheme)
    end
end

---@param spec user.plugin.PluginSpec
function M.colorscheme_spec(spec)
    spec.after_finalization = M.after_color_scheme_loaded
    return spec
end

-- Looing for a directory recrusively in parent
---@param target_names string[] # target directory name
---@return boolean is_found
local function find_root_by_directory(target_names)
    local pwd = vim.fn.getcwd()

    local is_found = false
    for _, target_name in ipairs(target_names) do
        if vim.fn.isdirectory(pwd .. "/" .. target_name) == 1 then
            is_found = true
            break
        end

        for dir in vim.fs.parents(pwd) do
            if vim.fn.isdirectory(dir .. "/" .. target_name) == 1 then
                is_found = true
                break
            end
        end
    end

    return is_found
end

---@param target_names string[] # target directory name
---@return fun(): boolean
function M.root_directory_cond(target_names)
    return function()
        return find_root_by_directory(target_names)
    end
end

-- Looing for a file recrusively in parent
---@param target_names string[] # target file name
---@return boolean is_found
local function find_root_by_file(target_names)
    local pwd = vim.fn.getcwd()

    local is_found = false
    for _, target_name in ipairs(target_names) do
        if vim.fn.filereadable(pwd .. "/" .. target_name) == 1 then
            is_found = true
            break
        end

        for dir in vim.fs.parents(pwd) do
            if vim.fn.filereadable(dir .. "/" .. target_name) == 1 then
                is_found = true
                break
            end
        end
    end

    return is_found
end

---@param target_names string[] # target file name
---@return fun(): boolean
function M.root_file_cond(target_names)
    return function()
        return find_root_by_file(target_names)
    end
end

return M
