local env_config = require "user.base.env"
if not env_config.ENV_CONFIG_INIT_OK then
    return { finalize = function() end }
end

local util = require "user.util"
local log_uitl = require "user.util.log"
local config_entry = require "user.base.config_entry"

local import = util.import

log_uitl.log_level = vim.log.levels.WARN

local user = config_entry.ConfigEntry:new {
    env = env_config,
} --[[@as UserConfig]]

-- ----------------------------------------------------------------------------

-- chdir to directory of first file in command line arguments.
-- This directory will be workspace directory of this run.
local function chdir()
    local result = vim.api.nvim_exec2("args", { output = true })
    local output = result.output or ""
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
    local cfg_autocmd = import "user.config.autocmd"
    local cfg_command = import "user.config.command"
    local cfg_diagnostics = import "user.config.diagnostics"
    local cfg_filetype = import "user.config.filetype"
    local cfg_theme = import "user.config.theme"
    local cfg_keybinding = import "user.config.keybinding"
    local cfg_lsp = import "user.config.lsp"
    local cfg_option = import "user.config.option"
    local cfg_platform = import "user.config.platform"
    local cfg_plugin = import "user.config.plugin"
    local cfg_workspace = import "user.config.workspace"

    util.do_async_steps {
        function(next_step)
            cfg_workspace.load(next_step)
        end,
        function(next_step)
            util.finalize_async({
                cfg_option,
                cfg_command,
                cfg_diagnostics,
                cfg_filetype,
                cfg_keybinding,
                cfg_lsp,
                cfg_platform,
                cfg_theme,
                cfg_workspace,
                cfg_autocmd,
                cfg_plugin,
            }, next_step)
        end,
    }
end

-- ----------------------------------------------------------------------------

local function setup_environment()
    chdir()

    vim.o.shortmess = vim.o.shortmess .. "I" -- disable intro screen message
    vim.o.laststatus = 0                     -- disable staus line in intro screen
    vim.o.fillchars = "eob: "                -- remove `~` at eob lines
    vim.o.cmdheight = 0                      -- hide cmdline

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
        once = true,
        callback = on_plugins_loaded,
    })

    vim.api.nvim_create_autocmd("User", {
        group = finalize_augroup,
        pattern = "LazyVimStarted",
        once = true,
        callback = function()
            vim.fn.timer_start(200, show_editor_state)
        end,
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
