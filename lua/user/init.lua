local utils = require "user.utils"
local import = utils.import
local fs = require "user.utils.fs"
local ConfigEntry = require "user.config_entry".ConfigEntry

local env_config_home = vim.env.CONFIG_HOME
if  not env_config_home then
    vim.notify("failed to initialize, Can't find environment variable 'CONFIG_HOME'")
    return
end

local user = ConfigEntry:new {
    env = {
        NVIM_HOME = fs.path_join(env_config_home, "nvim"),
        CONFIG_HOME = fs.path_join(env_config_home, "nvim", "lua"),
    }
}

-- copying variables in user namespace into vim namespace.
---@param key string|string[] # if a list of string is passed, each element in the list is treated as a key.
local function load_into_vim(key)
    if type(key) == "string" then
        key = { key }
    end

    for _, k in ipairs(key) do
        local optioins = user[k]
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

rawset(user, "finalize", function()
    chdir()

    -- loading custom loader
    require "user.utils.module_loaders"

    local modules = {
        -- load plugins first, make sure all config file can `require` them.
        import "user.plugins",

        -- user config
        import "user.command",
        import "user.general",
        import "user.keybinding",
        import "user.snippets",

        -- platform specific config
        import "user.platforms",

        -- workspace config
        import "user.workspace".load(),
    }

    -- settle vim variables.
    load_into_vim { "o", "wo", "g", "go" }

    -- finalize all loaded configs
    utils.finalize(modules)
end)

return user
