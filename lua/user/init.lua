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
---@param key string|string[] # if a list of string is passed, each element in the list is treated as a key.
local function load_into_vim(key)
    if type(key) == "string" then
        key = { key }
    end

    for _, k in ipairs(key) do
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
    local filepath = fs.path_join(user.env.CONFIG_HOME(), "user", "meta", "user_config.lua")
    config_entry.dump_signature(user --[[@as ConfigEntry]], filepath)
end

-- ----------------------------------------------------------------------------

local function on_plugins_loaded()
    local workspace = import "user.workspace"

    workspace.load()

    -- settle vim variables.
    load_into_vim { "o", "g", "go" }

    -- finalize all loaded configs
    utils.finalize {
        import "user.utils.plugin_loaders.lazy",

        -- user config
        import "user.config.general",
        import "user.config.keybinding",
        import "user.config.snippets",
        import "user.config.command",

        -- platform specific config
        import "user.platforms",

        -- workspace config
        workspace,
    }

    dump_user_config_meta()
end

rawset(user, "finalize", function()
    chdir()

    -- loading custom loader
    require "user.utils.module_loaders".setup {
        config_home = user.env.CONFIG_HOME(),
    }

    -- wait for plugins get loaded
    local finalize_augroup = vim.api.nvim_create_augroup("user.finalize", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = finalize_augroup,
        pattern = "LazyDone",
        callback = on_plugins_loaded,
    })

    -- load plugins
    local plugin_specs = require "user.config.plugins"
    local plugin_loader = require "user.utils.plugin_loaders.lazy"
    plugin_loader.setup(plugin_specs)
end)

return user
