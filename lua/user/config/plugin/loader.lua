local user = require "user"
local plugin_util = require "user.config.plugin.util"
local util = require "user.util"
local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local manager = require "user.config.plugin.managers.lazy"

local fn = vim.fn
local get_plugin_name_from_spec = plugin_util.get_plugin_name_from_spec
local import = util.import

-- ----------------------------------------------------------------------------
-- loading helpers

---@param module_path string # module path relative to user config home directory
---@param reload boolean
---@return any?
local function load_plugin_module(module_path, reload)
    local file = fs_util.path_join(user.env.USER_RUNTIME_PATH(), module_path)
    if fn.filereadable(file) == 0 then
        return nil
    end

    if reload then
        package.loaded[file] = nil
    end

    return import(file)
end

---@param name string # plugin base name
local function get_config_path(name)
    return fs_util.path_join("user", "plugins", name, "config.lua")
end

---@param name string # plugin base name
local function get_keybinding_path(name)
    return fs_util.path_join("user", "plugins", name, "keybinding.lua")
end

-- ----------------------------------------------------------------------------

local is_finalized = false
local pending_spec_list = nil ---@type user.plugin.PluginSpec[] | nil

local load_spec = nil ---@type fun(spec: user.plugin.PluginSpec) | nil

-- a load checker that always returns true
---@return boolean
local function default_load_checker()
    return true;
end

-- Add plugin specification to postpone list.
---@param spec user.plugin.PluginSpec
local function add_pending_spec(spec)
    pending_spec_list = pending_spec_list or {}
    pending_spec_list[#pending_spec_list + 1] = spec
end

-- ----------------------------------------------------------------------------

---@alias EventLoadChecker fun(spec: user.plugin.PluginSpec, args: any): boolean

local lazy_load_augroup = vim.api.nvim_create_augroup("user.util.plugin_loader.lazy", { clear = true })
local lazy_load_autocmd_listener = {} ---@type table<string, table<user.plugin.PluginSpec, EventLoadChecker>>

---@param event string
---@param args table
local function on_autocmd_triggered(event, args)
    local channel = lazy_load_autocmd_listener[event]
    if not channel then return end

    log_util.trace("+ plugin event:", event)

    for spec, checker in pairs(channel) do
        local ok = checker(spec, args)
        if ok then
            local full_name = get_plugin_name_from_spec(spec)
            log_util.trace("  +", full_name or spec)

            if load_spec then
                load_spec(spec)
            end

            channel[spec] = nil
        end
    end

    if not next(channel) then
        log_util.trace("-", event, "\n", channel)
        lazy_load_autocmd_listener[event] = nil
    else
        log_util.trace("*", event)
    end
end

---@param event string
---@param spec user.plugin.PluginSpec
---@param checker EventLoadChecker
local function register_autocmd_listener(event, spec, checker)
    local channel = lazy_load_autocmd_listener[event]
    if not channel then
        channel = {}
        lazy_load_autocmd_listener[event] = channel

        vim.api.nvim_create_autocmd(event, {
            group = lazy_load_augroup,
            callback = function(args)
                on_autocmd_triggered(event, args)
            end
        })
    end

    channel[spec] = checker
end

local function remove_all_listeners_for_spec(spec)
    for _, set in pairs(lazy_load_autocmd_listener) do
        set[spec] = nil
    end
end

-- ----------------------------------------------------------------------------

-- Rune before command before adding plugin spec to load list
---@param spec user.plugin.PluginSpec
local function run_on_setup(spec)
    local on_setup = spec.on_setup
    local before_load_type = type(on_setup)

    if before_load_type == "string" then
        vim.cmd(on_setup)
    elseif before_load_type == "function" then
        on_setup()
    end
end

---@param spec user.plugin.PluginSpec
local function setup_lazy_event(spec)
    local lazy_info = spec.lazy_load
    if not lazy_info then return end

    local event = lazy_info.event
    if not event then return false end

    local plugin_name = get_plugin_name_from_spec(spec)
    if not plugin_name then
        log_util.warn("can't setup lazy load event, not plugin name found", spec)
        return
    end

    local checker = lazy_info.event_load_checker or default_load_checker

    if type(event) == "string" then
        register_autocmd_listener(event, spec, checker)
    elseif type(event) == "table" then
        for _, value in ipairs(event) do
            if type(value) == "string" then
                register_autocmd_listener(value, spec, checker)
            else
                log_util.warn(
                    "lazy load event should be valid autocmd name string",
                    value
                )
            end
        end
    end
end

-- Check if a specification is config to used custom autocmd handler. If so,
-- register it to autocmd channel. After registration, spec will be modified to
-- `lazy = true` and `event` field will be removed.
---@param spec user.plugin.PluginSpec
local function setup_lazy_load(spec)
    setup_lazy_event(spec)
end

---@param spec string | user.plugin.PluginSpec
local function setup_plugin_sepc(spec)
    if type(spec) == "table" and spec.enabled ~= false then
        run_on_setup(spec)
        setup_lazy_load(spec)
    end
end

-- Import config modules of a plugin.
---@param plugin_name string
---@param reload? boolean
---@return any[] | nil
local function load_config_modules(plugin_name, reload)
    reload = reload or false

    local plugin_basename = vim.fs.basename(plugin_name)
    local paths = {
        get_config_path(plugin_basename),
        get_keybinding_path(plugin_basename),
    }

    local modules = {}
    for _, path in ipairs(paths) do
        modules[#modules + 1] = load_plugin_module(path, reload)
    end

    return modules
end

-- Load and finalize config modules of plugin.
---@param spec user.plugin.PluginSpec
local function finalize_plugin_config(spec)
    local plugin_name = get_plugin_name_from_spec(spec)
    if not plugin_name then
        log_util.warn("failed to load plugin config: spec has no name", spec)
        return
    end

    local modules = load_config_modules(plugin_name)
    if modules then
        for _, item in ipairs(modules) do
            local ok = util.finalize_module(item)
            if not ok then
                log_util.warn("failed to finalize plugin config:", plugin_name)
            end
        end
    end

    local on_finalized = spec.on_finalized
    if on_finalized then
        on_finalized()
    end

    remove_all_listeners_for_spec(spec)

    log_util.trace("    *", plugin_name)
end

local function finalize_all_pending_spec()
    if not pending_spec_list then return end

    for _, spec in ipairs(pending_spec_list) do
        finalize_plugin_config(spec)
    end

    pending_spec_list = nil
end

---@param spec user.plugin.PluginSpec
local function on_plugin_loaded(spec)
    if is_finalized or spec.no_pending then
        finalize_plugin_config(spec)
    else
        add_pending_spec(spec)
    end
end

-- ----------------------------------------------------------------------------

local M = {}

---@param specs user.plugin.PluginSpec[]
function M.setup(specs)
    for _, spec in ipairs(specs) do
        setup_plugin_sepc(spec)
    end

    if log_util.log_level == vim.log.levels.TRACE then
        setup_lazy_event {
            name = "observer",
            lazy_load = {
                event = "FileType",
                event_load_checker = function()
                    return false
                end,
            }
        }
    end

    load_spec = manager.load
    manager.setup(specs, on_plugin_loaded)
end

function M.finalize()
    is_finalized = true
    finalize_all_pending_spec()
end

-- Utility function that loads config file of all plugins no matter they are
-- activated or not.
---@param specs user.plugin.PluginSpec[]
function M.load_all_plugin_config(specs)
    if not M._is_finalized then
        log_util.info("plugin loader is not finalized yet")
        return
    end

    for _, spec in ipairs(specs) do
        local plugin_name = get_plugin_name_from_spec(spec)
        if plugin_name then
            load_config_modules(plugin_name, true)
        end
    end
end

return M
