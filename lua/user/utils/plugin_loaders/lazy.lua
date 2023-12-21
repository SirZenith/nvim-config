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

-- ----------------------------------------------------------------------------
-- loading helpers

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
    local before_load = spec.__before_load
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
M._pending_finalizer = {} ---@type table<string, any>

---@param plugin_name string # name of then plugin target config belongs to
---@param config_name string # name to use when display this plugin in lazy.nvim UI
---@param config_path string # file path relative to user config home directory
---@return lazy.PluginSpec? # plugin spec for loading configuration
function M._make_config_spec(plugin_name, config_name, config_path)
    local file = fs.path_join(user.env.CONFIG_HOME(), config_path)
    if fn.filereadable(file) == 0 then
        return nil
    end

    local module = import(file)

    return {
        name = config_name,
        dir = file,
        config = function()
            M._pending_finalizer[config_name] = module
        end,
        dependencies = { plugin_name },
    }
end

---@param spec lazy.PluginSpec
---@return lazy.PluginSpec[] | nil
function M._load_config(spec)
    if M._is_bootstrap then return nil end

    local spec_type = type(spec)

    if spec_type == "table" and spec.dir then
        -- local plugin
        return
    end

    local path
    if spec_type == "table" then
        path = spec.enabled ~= false and spec[1] or nil
    elseif spec_type == "string" then
        path = spec
    end

    if not path or #path == 0 then return end

    local qualified_path = path:gsub("/", "::")
    local results = {}

    table.insert(results, M._make_config_spec(
        path,
        qualified_path .. "::config",
        get_config_path(path)
    ))

    table.insert(results, M._make_config_spec(
        path,
        qualified_path .. "::keybinding",
        get_keybinding_path(path)
    ))

    return results
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
        table.insert(targets, spec)

        handling_before_load_cmd(spec)

        local config_specs = M._load_config(spec)
        if config_specs then
            for _, config_spec in ipairs(config_specs) do
                table.insert(targets, config_spec)
            end
        end
    end

    manager.setup(targets)

    return M
end

function M.try_finalize_plugin_configs()
    for name, module in pairs(M._pending_finalizer) do
        local module_type = type(module)

        local final
        if module_type == "function" then
            final = module
        elseif module_type == "table" then
            final = module.finalize
        end

        if type(final) == "function" then
            final()
        end

        M._pending_finalizer[name] = nil
    end
end

function M.finalize()
    M.try_finalize_plugin_configs()

    M.init_plugin_config_update_event()
end

return M
