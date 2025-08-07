local env_config = require "user.base.env"

if env_config.ENABLE_BYTE_CODE then
    require("user.util.module_loaders").init {
        enable_byte_code = true,
        user_runtime_path = env_config.USER_RUNTIME_PATH,
    }
end

local util = require "user.util"
local log_uitl = require "user.util.log"
local config_entry = require "user.base.config_entry"

local import = util.import

log_uitl.log_level = vim.log.levels.WARN

local user = config_entry.ConfigEntry:new({
    env = env_config,
}) --[[@as UserConfig]]

-- ----------------------------------------------------------------------------

-- chdir to directory of first file in command line arguments.
-- This directory will be workspace directory of this run.
local function chdir()
    local result = vim.api.nvim_exec2("args", { output = true })
    local output = result.output or ""
    local cur_file = output:match("%[(.+)%]")

    local dir_path ---@type string?
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
    ---@module "uv"
    local uv = vim.uv

    ---@type (boolean | table | function)[]
    local module_list = {}

    local default_order = 100
    ---@type table<string, integer>
    local finalize_order_tbl = {
        ["option.lua"] = 1, -- first module to finalize
        ["plugin"] = 1000,  -- last module to finalize
    }

    local config_dir = vim.fs.joinpath(user.env.USER_RUNTIME_PATH(), "user", "config")

    util.do_async_steps {
        function(next_step)
            uv.fs_scandir(config_dir, vim.schedule_wrap(next_step))
        end,
        function(next_step, err, data)
            if err then
                log_uitl.error("failed to read config directory", err)
                return
            end

            if not data then
                log_uitl.warn("config directory scanning returns nil data")
                return
            end

            local name_list = {}
            local name = uv.fs_scandir_next(data)
            while name do
                table.insert(name_list, name)
                name = uv.fs_scandir_next(data)
            end

            table.sort(name_list, function(a, b)
                local order_a = finalize_order_tbl[a] or default_order
                local order_b = finalize_order_tbl[b] or default_order
                return order_a < order_b
            end)

            for _, element in ipairs(name_list) do
                local len = #element
                if element:sub(len - 3) == ".lua" then
                    element = element:sub(1, len - 4)
                end

                table.insert(module_list, import("user.config." .. element))
            end

            next_step()
        end,
        function(next_step)
            import "user.config.workspace".load(next_step)
        end,
        function(next_step)
            util.finalize_async(module_list, next_step)
        end,
        function(next_step)
            vim.defer_fn(function()
                vim.api.nvim_exec_autocmds("User", {
                    pattern = "UserConfigFinalized",
                })
            end, 500)
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
    require("user.util.module_loaders").init {
        enable_byte_code = false,
        user_runtime_path = env_config.USER_RUNTIME_PATH,
    }
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
            vim.defer_fn(show_editor_state, 200)
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
