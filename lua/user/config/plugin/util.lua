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

-- copy key-value pairs from src table to dst table. For all src's keys, if they
-- are assigned a value other than `false` in field_map, then that value will be
-- used as key to update dst table; if `false` is assigned, that thoese keys will
-- be discarded; if they are not presented in field_map, the original key will
-- be used as is to update dst.
---@param dst table
---@param src table
---@param field_map table
function M.map_plugin_spec_fields(dst, src, field_map)
    for key, value in pairs(src) do
        local map_to = field_map[key]

        if map_to == nil then
            dst[key] = value
        elseif map_to ~= false then
            dst[map_to] = value
        end
    end
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

-- Cache table for generated user config spec.
---@type table<string | user.plugin.UserConfigSpec, user.plugin.PluginSpec>
local UCS_CACHE = {};

---@param module_info string | user.plugin.UserConfigSpec
---@return user.plugin.PluginSpec
function M.user_config_spec(module_info)
    local cached_spec = UCS_CACHE[module_info]
    if type(cached_spec) == "table" then
        return cached_spec
    end

    local env_config = require "user.config.env"

    ---@type user.plugin.UserConfigSpec
    local spec = {
        dir = env_config.USER_RUNTIME_PATH,
        config = M.user_config_init,
        config_no_defer = true,
        priority = 1000,
    }

    local info_type = type(module_info)
    if info_type == "string" then
        spec.name = module_info
    elseif info_type == "table" then
        for key, value in pairs(module_info) do
            spec[key] = value;
        end
    end

    if not spec.no_auto_dependencies then
        spec.dependencies = {
            {
                "user.config.general",
                name = "user.config.general",
                dir = env_config.USER_RUNTIME_PATH
            },
        }
    end

    UCS_CACHE[module_info] = spec

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
    spec.on_finalized = M.after_color_scheme_loaded
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

        if is_found then
            break
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
function M.find_root_by_file(target_names)
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
        return M.find_root_by_file(target_names)
    end
end

---@param target_names string[] # target entry names
---@return fun(): boolean
function M.fs_entry_cond(target_names)
    return function()
        return M.find_root_by_directory(target_names) or M.find_root_by_file(target_names)
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
