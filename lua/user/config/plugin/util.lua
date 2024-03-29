local log_util = require "user.util.log"

local M = {}

---@param spec string | user.plugin.PluginSpec
---@return string?
function M.get_plugin_name_from_spec(spec)
    local spec_type = type(spec)

    local name
    if spec_type == "table" and spec.enabled ~= false then
        name = spec[1] or spec.name
    elseif spec_type == "string" then
        name = spec
    end

    return name
end

---@param spec user.plugin.PluginSpec
function M.user_config_init(spec)
    local module = spec.name
    if not module then
        log_util.warn("can't find `name` in spec for user config module")
        return
    end

    require(spec.name)
end

---@param module_name string
---@return  user.plugin.PluginSpec?
function M.user_config_spec(module_name)
    local env_config = require "user.config.env"

    ---@type user.plugin.PluginSpec
    local spec = {
        name = module_name,
        dir = env_config.USER_RUNTIME_PATH,
        config = M.user_config_init,
        config_no_defer = true,
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
    local colorscheme = user.general.theme.colorscheme()
    if colorscheme and colorscheme ~= "" then
        vim.cmd("colorscheme " .. colorscheme)
    end

    for group, config in user.general.theme.highlight:pairs() do
        vim.api.nvim_set_hl(0, group, config)
    end
end

---@param spec user.plugin.PluginSpec
function M.colorscheme_spec(spec)
    spec.priority = 100
    spec.after_finalization = M.after_color_scheme_loaded
    return spec
end

-- Looing for a directory recrusively in parent
---@param target_names string[] # target directory name
---@return boolean is_found
function M.find_root_by_directory(target_names)
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
        return M.find_root_by_directory(target_names)
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

local IGNORE_FILETYPE_TRIGGER = {
    [""] = true,
    oil = true,
}

-- Check if autocmd event of a buffer is valid for triggering a plugin to load.
---@return boolean
function M.buffer_enter_trigger_loading_predicate()
    local filetype = vim.bo.filetype
    if IGNORE_FILETYPE_TRIGGER[filetype] then
        return false
    end

    return true
end

-- Check if BufNew event is valid for triggering a plugin to load.
---@param args table
---@return boolean
function M.new_buffer_trigger_loading_predicate(spec, args)
    local file = args.file
    if not file or file == "" then
        return false
    end

    local prefix = "oil://"
    if file:sub(1, #prefix) == prefix then
        return false
    end

    return true
end

return M
