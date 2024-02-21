local env_config = require "user.config.env"
if not env_config.ENV_CONFIG_INIT_OK then
    return { finalize = function() end }
end

local util = require "user.util"
local config_entry = require "user.config.config_entry"

local import = util.import

local user = config_entry.ConfigEntry:new {
    env = env_config,
} --[[@as UserConfig]]

-- ----------------------------------------------------------------------------

-- copying variables in user namespace into vim namespace.
---@param ... string # if a list of string is passed, each element in the list is treated as a key.
local function load_into_vim(...)
    local keys = { ... }

    local option_tbl = user.general.option()
    for _, k in ipairs(keys) do
        local options = option_tbl[k]
        if not options then return end

        local target = vim[k]
        for field, value in pairs(options) do
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

-- Show editor starup state notification.
local function show_editor_state()
    local msg_buffer = {}

    local time = require "lazy".stats().startuptime
    table.insert(msg_buffer, "startup time: " .. tostring(time) .. "ms")

    local workspace = import "user.config.workspace"
    if workspace and workspace.is_workspace_confg_loaded() then
        table.insert(msg_buffer, "workspace configuration loaded.")
    end

    local msg = table.concat(msg_buffer, "\n")
    util.notify(msg, vim.log.levels.INFO, {
        title = "Editor State",
        timeout = 800,
        animated = false,
    })
end

-- Finalize plugin configs.
local function on_plugins_loaded()
    local workspace = import "user.config.workspace"

    util.do_async_steps {
        function(next_step)
            workspace.load(next_step)
        end,
        function(next_step)
            load_into_vim("o", "g", "go")

            util.finalize_async({
                import "user.config.general",
                import "user.config.filetype",
                import "user.config.keybinding",
                import "user.config.command",
                import "user.config.lsp",
                import "user.config.platforms",
                workspace,
                import "user.config.plugin"
            }, next_step)
        end,
        function()
            show_editor_state()
        end
    }
end

-- ----------------------------------------------------------------------------

local function setup_environment()
    chdir()

    vim.o.shortmess = vim.o.shortmess .. "I" -- disable intro screen message
    vim.o.laststatus = 0                     -- disable staus line in intro screen
    vim.o.fillchars = "eob: "                -- remove `~` at eob lines

    -- loading custom loader
    local module_loaders = import "user.util.module_loaders"
    if module_loaders then
        module_loaders.setup {
            user_runtime_path = user.env.USER_RUNTIME_PATH(),
        }
    end
end

local function setup_init_autocmd()
    local finalize_augroup = vim.api.nvim_create_augroup("user.finalize", { clear = true })

    vim.api.nvim_create_autocmd("User", {
        group = finalize_augroup,
        pattern = "LazyDone",
        callback = on_plugins_loaded,
        once = true,
    })
end

local function setup_plugin()
    import "user.config.plugin".init()
end

-- ----------------------------------------------------------------------------

rawset(user, "finalize", function()
    setup_environment()
    setup_init_autocmd()
    setup_plugin()
end)

return user
