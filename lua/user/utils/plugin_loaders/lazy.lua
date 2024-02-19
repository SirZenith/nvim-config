local base_config = require "user.config"

local user = require "user"
local utils = require "user.utils"
local import = utils.import
local fs = require "user.utils.fs"

local fn = vim.fn

local function require_manager()
    if vim.fn.executable("git") == 0 then
        error("can't find command git")
    end

    local is_bootstrap = false
    local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.loop.fs_stat(install_path) then
        is_bootstrap = true

        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            install_path,
        })
    end

    vim.opt.rtp:prepend(install_path)

    return is_bootstrap, import "lazy"
end

local is_bootstrap, manager = require_manager()

local manager_config = {
    dev = {
        path = base_config.env.PLUGIN_DEV_PATH,
        fallback = false,
    },
}

-- ----------------------------------------------------------------------------
-- loading helpers

---@param spec lazy.PluginSpec | string
---@return string? name
local function get_plugin_name_from_spec(spec)
    local spec_type = type(spec)

    local name
    if spec_type == "table" then
        name = spec.enabled ~= false and spec[1] or spec.name
    elseif spec_type == "string" then
        name = spec
    end

    return name
end

---@param name string # plugin spec name
local function get_config_path(name)
    return fs.path_join("user", "plugins", name, "config.lua")
end

---@param name string # plugin spec name
local function get_keybinding_path(name)
    return fs.path_join("user", "plugins", name, "keybinding.lua")
end

-- Rune before command before adding plugin spec to load list
---@param spec table
local function handling_before_load_cmd(spec)
    local before_load = spec.before_load
    local before_load_type = type(before_load)

    if before_load_type == "string" then
        vim.cmd(before_load)
    elseif before_load_type == "function" then
        before_load()
    end
end

---@param module_path string # module path relative to user config home directory
---@return any?
local function load_config_module(module_path)
    local file = fs.path_join(user.env.USER_RUNTIME_PATH(), module_path)
    if fn.filereadable(file) == 0 then
        return nil
    end

    return import(file)
end

-- ----------------------------------------------------------------------------

local M = {}

local augroup = vim.api.nvim_create_augroup("user.util.plugin_loader.lazy", { clear = true })

M._is_bootstrap = is_bootstrap
M._is_finalized = false
M._pending_spec_list = nil ---@type user.plugin.PluginSpec[] | nil
M._custom_autocmd_listener = {} ---@type table<string, table<user.plugin.PluginSpec, true>>

---@param event string
---@param args table
function M._on_autocmd_triggered(event, args)
    local set = M._custom_autocmd_listener[event]
    if not set then return end

    local is_empty = true
    for spec in pairs(set) do
        local ok = spec.autocmd_load_checker(spec, args)
        if ok then
            local full_name = get_plugin_name_from_spec(spec)
            if full_name then
                local segments = vim.split(full_name, "/")
                local name = segments[#segments]
                manager.load { plugins = { name } }
            end

            set[spec] = nil
        else
            is_empty = false
        end
    end

    if is_empty then
        M._custom_autocmd_listener[event] = nil
        return
    end
end

---@parevent string
---@param spec user.plugin.PluginSpec
function M._register_autocmd_listener(event, spec)
    local set = M._custom_autocmd_listener[event]
    if not set then
        set = {}
        M._custom_autocmd_listener[event] = set

        vim.api.nvim_create_autocmd(event, {
            group = augroup,
            callback = function(args)
                M._on_autocmd_triggered(event, args)
            end
        })
    end

    set[spec] = true
end

---@param spec user.plugin.PluginSpec
---@return boolean is_custom_load
function M._try_setup_spec_autocmd(spec)
    if not spec.autocmd_load_checker then
        return false
    end

    local event = spec.event
    if not event then
        vim.notify("plugin specified custom autocmd handler but doesn't provide autocmd name.", vim.log.WARN)
        vim.print(spec)
        return false
    end

    local is_custom = true

    if type(event) == "string" then
        M._register_autocmd_listener(event, spec)
    elseif type(event) == "table" then
        for _, value in ipairs(event) do
            if type(value) == "string" then
                M._register_autocmd_listener(value, spec)
            else
                vim.notify("autocmd name value for custom handler shoul be string", vim.log.levels.WARN)
                vim.print(value)
            end
        end
    else
        is_custom = true
    end

    return is_custom
end

---@param plugin_name string
---@return any[] | nil
function M._load_config_modules(plugin_name)
    if M._is_bootstrap then return nil end

    local paths = {
        get_config_path(plugin_name),
        get_keybinding_path(plugin_name),
    }

    local modules = {}
    for _, path in ipairs(paths) do
        modules[#modules + 1] = load_config_module(path)
    end

    return modules
end

---@param spec user.plugin.PluginSpec
function M._finalize_plugin_config(spec)
    local plugin_name = get_plugin_name_from_spec(spec)
    if not plugin_name then
        vim.notify("failed to load plugin config: spec has no name", vim.log.levels.WARN)
        vim.print(spec)
        return
    end

    local old_config_func = spec.old_config_func
    if old_config_func then
        old_config_func(spec)
    end

    local modules = M._load_config_modules(plugin_name)
    if modules then
        for _, item in ipairs(modules) do
            utils.finalize_module(item)
        end
    end

    local after_finalization = spec.after_finalization
    if after_finalization then
        after_finalization()
    end

    for _, set in pairs(M._custom_autocmd_listener) do
        set[spec] = nil
    end
end

---@param spec user.plugin.PluginSpec
function M._on_plugin_loaded(spec)
    if M._is_finalized or spec.config_no_defer then
        M._finalize_plugin_config(spec)
    else
        local pending_list = M._pending_spec_list
        if not pending_list then
            pending_list = {}
            M._pending_spec_list = pending_list
        end

        pending_list[#pending_list + 1] = spec
    end
end

---@param specs user.plugin.PluginSpec[]
function M.load_all_plugin_config(specs)
    if not M._is_finalized then
        vim.notify("plugin loader is not finalized yet")
        return
    end

    for _, spec in ipairs(specs) do
        local plugin_name = get_plugin_name_from_spec(spec)
        if plugin_name then
            M._load_config_modules(plugin_name)
        end
    end
end

---@param specs user.plugin.PluginSpec[]
function M.setup(specs)
    if M._is_bootstrap then return end

    local targets = {}

    for _, spec in ipairs(specs) do
        if type(spec) == "string" then
            spec = { spec }
        end

        handling_before_load_cmd(spec)

        spec.old_config_func = spec.config
        spec.config = M._on_plugin_loaded

        local is_custom_load = M._try_setup_spec_autocmd(spec)
        if is_custom_load then
            spec.event = nil
            spec.lazy = true
        end

        table.insert(targets, spec)
    end

    manager.setup(targets, manager_config)

    return M
end

function M.finalize()
    M._is_finalized = true

    local pending_list = M._pending_spec_list
    if pending_list then
        for _, spec in ipairs(pending_list) do
            M._finalize_plugin_config(spec)
        end
    end
    M._pending_spec_list = nil
end

return M
