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

M._is_bootstrap = is_bootstrap
M._is_finalized = false
M._pending_spec_list = nil ---@type user.plugin.PluginSpec[] | nil

---@param plugin_name string
---@return any[] | nil
function M._load_config_modules(plugin_name)
    if M._is_bootstrap then return nil end

    local modules = {
        get_config_path(plugin_name),
        get_keybinding_path(plugin_name),
    }

    for i, path in ipairs(modules) do
        modules[i] = load_config_module(path)
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
end

---@param spec user.plugin.PluginSpec
function M._run_plugin_config(spec)
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
        spec.config = M._run_plugin_config

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
