local env_config = require "user.config.env"

local user = require "user"
local plugin_util = require "user.config.plugin.util"
local util = require "user.util"
local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local loop = vim.uv or vim.loop
local fs_stat = loop.fs_stat
local fn = vim.fn
local get_plugin_name_from_spec = plugin_util.get_plugin_name_from_spec
local import = util.import

local function require_manager()
    if vim.fn.executable("git") == 0 then
        error("can't find command git")
    end

    local is_bootstrap = false
    local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not fs_stat(install_path) then
        is_bootstrap = true

        vim.notify("Plugin manger bootstrap...")
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            install_path,
        })
        vim.notify("Complete.")
    end

    vim.opt.rtp:prepend(install_path)

    return is_bootstrap, import "lazy"
end

local is_bootstrap, manager = require_manager()

local manager_config = {
    -- directory where plugins will be installed
    root = vim.fn.stdpath("data") .. "/lazy",

    defaults = {
        -- should plugins be lazy-loaded?
        lazy = false,
        version = nil,
        -- default `cond` you can use to globally disable a lot of plugins
        -- when running inside vscode for example
        cond = nil, ---@type boolean|fun(self:lazy.PluginSpec):boolean|nil
        -- enable this to try installing the latest stable versions of plugins
        -- version = "*",
    },

    -- leave nil when passing the spec as the first argument to setup()
    ---@type lazy.PluginSpec
    spec = nil,

    -- lockfile generated after running update.
    lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",

    -- limit the maximum amount of concurrent tasks
    ---@type number?
    concurrency = jit.os:find("Windows") and (loop.available_parallelism() * 2) or nil,

    git = {
        -- defaults for the `Lazy log` command
        log = {
            "-10", -- show the last 10 commits
            "-8",  -- show commits from the last 3 days
        },
        -- kill processes that take more than 2 minutes
        timeout = 120,
        url_format = "https://github.com/%s.git",
        -- lazy.nvim requires git >=2.19.0. If you really want to use lazy with an older version,
        -- then set the below to false. This should work, but is NOT supported and will
        -- increase downloads a lot.
        filter = true,
    },

    dev = {
        -- directory where you store your local plugin projects
        ---@type string | fun(plugin: user.plugin.PluginSpec): string
        path = env_config.PLUGIN_DEV_PATH,
        -- plugins that match these patterns will use your local versions instead
        -- of being fetched from GitHub
        -- For example {"folke"}
        ---@type string[]
        patterns = {},
        -- Fallback to git when local plugin doesn't exist
        fallback = false,
    },

    install = {
        -- install missing plugins on startup. This doesn't increase startup time.
        missing = true,
        -- try to load one of these colorschemes when starting an installation during startup
        colorscheme = { "habamax" },
    },

    ui = {
        -- a number <1 is a percentage., >1 is a fixed size
        size = { width = 0.8, height = 0.8 },
        -- wrap the lines in the ui
        wrap = false,
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "none",
        -- only works when border is not "none"
        ---@type string
        title = nil,
        ---@type "center" | "left" | "right"
        title_pos = "center",
        -- Show pills on top of the Lazy window
        ---@type boolean
        pills = true,
        icons = {
            cmd = " ",
            config = "",
            event = "",
            ft = " ",
            init = " ",
            import = " ",
            keys = " ",
            lazy = "󰒲 ",
            loaded = "●",
            not_loaded = "○",
            plugin = " ",
            runtime = " ",
            require = "󰢱 ",
            source = " ",
            start = "",
            task = "✔ ",
            list = {
                "●",
                "➜",
                "★",
                "‒",
            },
        },
        -- leave nil, to automatically select a browser depending on your OS.
        -- If you want to use a specific browser, you can define it here
        ---@type string?
        browser = nil,
        -- how frequently should the ui process render events
        throttle = 20,
        custom_keys = {
            -- You can define custom key maps here. If present, the description
            -- will be shown in the help menu.
            -- To disable one of the defaults, set it to false.

            ["<localleader>l"] = {
                function(plugin)
                    require("lazy.util").float_term({ "lazygit", "log" }, {
                        cwd = plugin.dir,
                    })
                end,
                desc = "Open lazygit log",
            },

            ["<localleader>t"] = {
                function(plugin)
                    require("lazy.util").float_term(nil, {
                        cwd = plugin.dir,
                    })
                end,
                desc = "Open terminal in plugin dir",
            },
        },
    },
    diff = {
        -- diff command <d> can be one of:
        -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
        --   so you can have a different command for diff <d>
        -- * git: will run git diff and open a buffer with filetype git
        -- * terminal_git: will open a pseudo terminal with git diff
        -- * diffview.nvim: will open Diffview to show the diff
        cmd = "git",
    },
    checker = {
        -- automatically check for plugin updates
        enabled = false,
        -- set to 1 to check for updates very slowly
        ---@type number?
        concurrency = nil,
        -- get a notification when new updates are found
        notify = true,
        -- check for updates every hour
        frequency = 3600,
        -- check for pinned packages that can't be updated
        check_pinned = false,
    },
    change_detection = {
        -- automatically check for config file changes and reload the ui
        enabled = true,
        -- get a notification when changes are found
        notify = true,
    },
    performance = {
        cache = {
            enabled = true,
        },
        -- reset the package path to improve startup time
        reset_packpath = true,
        rtp = {
            -- reset the runtime path to $VIMRUNTIME and your config directory
            reset = true,
            -- add any custom paths here that you want to includes in the rtp
            ---@type string[]
            paths = {},
            -- list any plugins you want to disable here
            ---@type string[]
            disabled_plugins = {
                -- "gzip",
                -- "matchit",
                -- "matchparen",
                "netrwPlugin",
                -- "tarPlugin",
                -- "tohtml",
                "tutor",
                -- "zipPlugin",
            },
        },
    },
    -- lazy can generate helptags from the headings in markdown readme files,
    -- so :help works even for plugins that don't have vim docs.
    -- when the readme opens with :help it will be correctly displayed as markdown
    readme = {
        enabled = true,
        root = vim.fn.stdpath("state") .. "/lazy/readme",
        files = { "README.md", "lua/**/README.md" },
        -- only generate markdown helptags for plugins that dont have docs
        skip_if_doc_exists = true,
    },
    -- state info for checker and other things
    state = vim.fn.stdpath("state") .. "/lazy/state.json",
    build = {
        -- Plugins can provide a `build.lua` file that will be executed when the plugin is installed
        -- or updated. When the plugin spec also has a `build` command, the plugin's `build.lua` not be
        -- executed. In this case, a warning message will be shown.
        warn_on_override = true,
    },
    -- Enable profiling of lazy.nvim. This will add some overhead,
    -- so only enable this when you are debugging lazy.nvim
    profiling = {
        -- Enables extra stats on the debug tab related to the loader cache.
        -- Additionally gathers stats about all package.loaders
        loader = false,
        -- Track each new require in the Lazy profiling tab
        require = false,
    },
}

-- ----------------------------------------------------------------------------
-- loading helpers

---@param name string # plugin base name
local function get_config_path(name)
    return fs_util.path_join("user", "plugins", name, "config.lua")
end

---@param name string # plugin base name
local function get_keybinding_path(name)
    return fs_util.path_join("user", "plugins", name, "keybinding.lua")
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
---@param reload boolean
---@return any?
local function load_config_module(module_path, reload)
    local file = fs_util.path_join(user.env.USER_RUNTIME_PATH(), module_path)
    if fn.filereadable(file) == 0 then
        return nil
    end

    if reload then
        package.loaded[file] = nil
    end

    return import(file)
end

-- ----------------------------------------------------------------------------

local M = {}

local augroup = vim.api.nvim_create_augroup("user.util.plugin_loader.lazy", { clear = true })

M._is_bootstrap = is_bootstrap
M._is_finalized = false
M._pending_spec_list = nil ---@type user.plugin.PluginSpec[] | nil
M._custom_autocmd_listener = {} ---@type table<string, table<user.plugin.PluginSpec, true>>

-- Add plugin specification to postpone list.
---@param spec user.plugin.PluginSpec
function M._add_pending_spec(spec)
    local pending_list = M._pending_spec_list
    if not pending_list then
        pending_list = {}
        M._pending_spec_list = pending_list
    end

    pending_list[#pending_list + 1] = spec
end

-- Finalize all postpone plugin configs.
function M._finalize_all_pending_spec()
    local pending_list = M._pending_spec_list
    if pending_list then
        for _, spec in ipairs(pending_list) do
            M._finalize_plugin_config(spec)
        end
    end
    M._pending_spec_list = nil
end

---@param event string
---@param args table
function M._on_autocmd_triggered(event, args)
    local set = M._custom_autocmd_listener[event]
    if not set then return end

    log_util.trace("+ plugin event:", event)

    for spec in pairs(set) do
        local ok = spec.autocmd_load_checker(spec, args)
        if ok then
            local full_name = get_plugin_name_from_spec(spec)
            log_util.trace("  +", full_name or spec)
            if full_name then
                local segments = vim.split(full_name, "/")
                local name = segments[#segments]
                manager.load { plugins = { name } }
            end

            set[spec] = nil
        end
    end

    if not next(set) then
        log_util.trace("-", event, "\n", set)
        M._custom_autocmd_listener[event] = nil
        return
    end
    log_util.trace("*", event)
end

---@param event string
---@param spec user.plugin.PluginSpec
function M._register_autocmd_listener(event, spec)
    local set = M._custom_autocmd_listener[event]
    if not set then
        set = {}
        M._custom_autocmd_listener[event] = set

        vim.api.nvim_create_autocmd(event, {
            group = augroup,
            callback = function(args)
                M._on_autocmd_triggered(event, args)
            end
        })
    end

    set[spec] = true
end

function M._remove_all_listeners_for_spec(spec)
    for _, set in pairs(M._custom_autocmd_listener) do
        set[spec] = nil
    end
end

-- Check if a specification is config to used custom autocmd handler. If so,
-- register it to autocmd channel. After registration, spec will be modified to
-- `lazy = true` and `event` field will be removed.
---@param spec user.plugin.PluginSpec
function M._try_setup_spec_autocmd(spec)
    local plugin_name = get_plugin_name_from_spec(spec)
    if not plugin_name then
        return
    end

    if not spec.autocmd_load_checker then
        return false
    end

    local event = spec.event
    if not event then
        log_util.warn(
            "plugin specified custom autocmd handler but doesn't provide autocmd name.",
            spec
        )
        return false
    end

    local is_custom = true

    if type(event) == "string" then
        M._register_autocmd_listener(event, spec)
    elseif type(event) == "table" then
        for _, value in ipairs(event) do
            if type(value) == "string" then
                M._register_autocmd_listener(value, spec)
            else
                log_util.warn(
                    "autocmd name value for custom handler should be string",
                    value
                )
            end
        end
    else
        is_custom = true
    end

    if is_custom then
        spec.event = nil
        spec.lazy = true
    end
end

-- Import config modules of a plugin.
---@param plugin_name string
---@param reload? boolean
---@return any[] | nil
function M._load_config_modules(plugin_name, reload)
    if M._is_bootstrap then return nil end

    reload = reload or false

    local plugin_basename = vim.fs.basename(plugin_name)
    local paths = {
        get_config_path(plugin_basename),
        get_keybinding_path(plugin_basename),
    }

    local modules = {}
    for _, path in ipairs(paths) do
        modules[#modules + 1] = load_config_module(path, reload)
    end

    return modules
end

-- Load and finalize config modules of plugin.
---@param spec user.plugin.PluginSpec
function M._finalize_plugin_config(spec)
    local plugin_name = get_plugin_name_from_spec(spec)
    if not plugin_name then
        log_util.warn("failed to load plugin config: spec has no name", spec)
        return
    end

    local old_config_func = spec.old_config_func
    if old_config_func then
        old_config_func(spec)
    end

    local modules = M._load_config_modules(plugin_name)
    if modules then
        for _, item in ipairs(modules) do
            local ok = util.finalize_module(item)
            if not ok then
                log_util.warn("failed to finalize plugin config:", plugin_name)
            end
        end
    end

    local after_finalization = spec.after_finalization
    if after_finalization then
        after_finalization()
    end

    M._remove_all_listeners_for_spec(spec)

    log_util.trace("    *", plugin_name)
end

---@param spec user.plugin.PluginSpec
function M._on_plugin_loaded(spec)
    if M._is_finalized or spec.config_no_defer then
        M._finalize_plugin_config(spec)
    else
        M._add_pending_spec(spec)
    end
end

---@param spec string | user.plugin.PluginSpec
function M._plugin_spec_preprocess(spec)
    if type(spec) == "string" then
        spec = { spec }
    end

    handling_before_load_cmd(spec)

    spec.old_config_func = spec.config
    spec.config = M._on_plugin_loaded

    M._try_setup_spec_autocmd(spec)
end

-- Load plugin specifications into plugin manager.
---@param specs user.plugin.PluginSpec[]
function M.setup(specs)
    if M._is_bootstrap then return end

    local targets = {}

    for _, spec in ipairs(specs) do
        M._plugin_spec_preprocess(spec)
        table.insert(targets, spec)
    end

    M._try_setup_spec_autocmd {
        name = "observer",
        event = "FileType",
        autocmd_load_checker = function()
            return false
        end,
    }

    manager.setup(targets, manager_config)

    return M
end

function M.finalize()
    M._is_finalized = true
    M._finalize_all_pending_spec()
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
            M._load_config_modules(plugin_name, true)
        end
    end
end

return M
