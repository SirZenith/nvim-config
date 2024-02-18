local base_config, err = require "user.config"
if err then
    return { finalize = function() end }
end

local utils = require "user.utils"
local fs = require "user.utils.fs"
local import = utils.import
local config_entry = require "user.utils.config_entry"

local user = config_entry.ConfigEntry:new(base_config) --[[@as UserConfig]]

-- ----------------------------------------------------------------------------

-- copying variables in user namespace into vim namespace.
---@param ... string # if a list of string is passed, each element in the list is treated as a key.
local function load_into_vim(...)
    local keys = { ... }

    for _, k in ipairs(keys) do
        local optioins = user.option[k]
        if not optioins then return end

        local target = vim[k]
        for field, value in optioins:pairs() do
            target[field] = value
        end
    end
end

-- chdir to directory of first file in command line arguments.
-- This directory will be workspace directory of this run.
local function chdir()
    local output = vim.api.nvim_command_output "args"
    local cur_file = output:match("%[(.+)%]")

    local dir_path
    if vim.fn.isdirectory(cur_file) == 1 then
        dir_path = cur_file
    elseif vim.fn.filereadable(cur_file) == 1 then
        dir_path = vim.fs.dirname(cur_file)
    end

    if dir_path then
        vim.fn.chdir(dir_path)
    end
end

-- dump user config Lua meta file to config home.
local function dump_user_config_meta()
    local filepath = fs.path_join(user.env.USER_RUNTIME_PATH(), "user", "meta", "user_config.lua")
    config_entry.dump_signature(user --[[@as ConfigEntry]], filepath)
end

-- Show editor starup state notification.
local function show_editor_state()
    local msg_buffer = {}

    local time = require("lazy").stats().startuptime
    table.insert(msg_buffer, "startup time: " .. tostring(time) .. "ms")

    local workspace = import "user.workspace"
    if workspace and workspace.is_workspace_confg_loaded() then
        table.insert(msg_buffer, "workspace configuration loaded.")
    end

    local msg = table.concat(msg_buffer, "\n")
    utils.notify(msg, vim.log.levels.INFO, {
        title = "Editor State",
        timeout = 800,
        animated = false,
    })
end

-- Finalize plugin configs.
local function on_plugins_loaded()
    local workspace = import "user.workspace"

    workspace.load()

    -- settle vim variables.
    load_into_vim("o", "g", "go")

    -- finalize all loaded configs
    utils.finalize {
        -- user config
        import "user.config.general",
        import "user.config.keybinding",
        import "user.config.command",
        import "user.config.lsp",
        import "user.config.platforms",

        -- workspace config
        workspace,

        -- plugins, get finalized after all user configurations are.
        import "user.utils.plugin_loaders.lazy",
    }

    dump_user_config_meta()
end

-- ----------------------------------------------------------------------------

local function setup_environment()
    chdir()

    -- disable Netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- loading custom loader
    require "user.utils.module_loaders".setup {
        user_runtime_path = user.env.USER_RUNTIME_PATH(),
    }
end

local function setup_init_autocmd()
    local finalize_augroup = vim.api.nvim_create_augroup("user.finalize", { clear = true })

    vim.api.nvim_create_autocmd("User", {
        group = finalize_augroup,
        pattern = "LazyDone",
        callback = on_plugins_loaded,
        once = true,
    })

    vim.api.nvim_create_autocmd("User", {
        group = finalize_augroup,
        pattern = "VeryLazy",
        callback = function()
            vim.fn.timer_start(1000, show_editor_state)
        end,
        once = true,
    })
end

local function setup_plugin()
    local plugin_specs = require "user.config.plugins"
    local plugin_loader = require "user.utils.plugin_loaders.lazy"
    plugin_loader.setup(plugin_specs)
end

-- ----------------------------------------------------------------------------

rawset(user, "finalize", function()
    setup_environment()
    setup_init_autocmd()
    setup_plugin()
end)

return user
