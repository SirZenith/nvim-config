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
    },
}

-- ----------------------------------------------------------------------------
-- loading helpers

---@param spec lazy.PluginSpec
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

-- ----------------------------------------------------------------------------

local M = {}

M._is_bootstrap = is_bootstrap
M._pending_finalizer = {} ---@type table<string, LazyFinalizerState>

---@param plugin_name string
---@return LazyFinalizerState
function M._get_pending_finalizer_state(plugin_name)
    local state = M._pending_finalizer[plugin_name]
    if not state then
        state = {
            loaded = false,
            modules = {}
        }
        M._pending_finalizer[plugin_name] = state
    end

    return state
end

---@param plugin_name string # name of then plugin target config belongs to
---@param config_path string # file path relative to user config home directory
function M._add_config_to_pending_table(plugin_name, config_path)
    local file = fs.path_join(user.env.USER_RUNTIME_PATH(), config_path)
    if fn.filereadable(file) == 0 then
        return nil
    end

    local state = M._get_pending_finalizer_state(plugin_name)

    table.insert(state.modules, import(file))
end

---@param spec PluginSpec
---@return lazy.PluginSpec[] | nil
function M._load_config(spec)
    if M._is_bootstrap then return nil end

    local plugin_name = get_plugin_name_from_spec(spec)
    if not plugin_name or #plugin_name == 0 then return end

    if spec.finalize_module then
        local state = M._get_pending_finalizer_state(plugin_name)
        table.insert(state.modules, spec.finalize_module)
    end

    local config_paths = {
        get_config_path(plugin_name),
        get_keybinding_path(plugin_name),
    }

    for _, config_path in ipairs(config_paths) do
        M._add_config_to_pending_table(plugin_name, config_path)
    end
end

function M.init_plugin_config_update_event()
    local plugin_augroup = vim.api.nvim_create_augroup("user.plugin.config-finalize", { clear = true })

    ---@type table<string, string | string[]>
    local finalize_events = {
        User = { "LazyLoad" },
    }

    for event_name, pattern in pairs(finalize_events) do
        vim.api.nvim_create_autocmd(event_name, {
            group = plugin_augroup,
            pattern = pattern,
            callback = M.try_finalize_plugin_configs,
        })
    end
end

function M.setup(specs)
    if M._is_bootstrap then return end

    local targets = {}
    for _, spec in ipairs(specs) do
        if type(spec) == "string" then
            spec = { spec }
        end

        handling_before_load_cmd(spec)

        local old_config = spec.config
        spec.config = function(...)
            if type(old_config) == "function" then
                old_config(...)
            end

            local plugin_name = get_plugin_name_from_spec(spec)
            if plugin_name then
                M.on_plugin_loaded(plugin_name)
            end
        end

        M._load_config(spec)

        table.insert(targets, spec)
    end

    manager.setup(targets, manager_config)

    return M
end

---@param plugin_name string
function M.on_plugin_loaded(plugin_name)
    local state = M._pending_finalizer[plugin_name]
    if not state then
        return
    end

    state.loaded = true
end

function M.try_finalize_plugin_configs()
    for name, state in pairs(M._pending_finalizer) do
        if state.loaded then
            for _, item in ipairs(state.modules) do
                local module = type(item) == "string" and import(item) or item
                utils.finalize_module(module)
            end
            M._pending_finalizer[name] = nil
        end
    end
end

function M.finalize()
    M.try_finalize_plugin_configs()
    M.init_plugin_config_update_event()
end

return M
