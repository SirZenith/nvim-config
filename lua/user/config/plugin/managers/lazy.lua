local env_config = require "user.base.env"

local plugin_util = require "user.config.plugin.util"
local util = require "user.util"

local import = util.import
local get_plugin_name_from_spec = plugin_util.get_plugin_name_from_spec

local function require_manager()
    if vim.fn.executable("git") == 0 then
        error("can't find command git")
    end

    local is_bootstrap = false
    local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.uv.fs_stat(install_path) then
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
    concurrency = jit.os:find("Windows") and (vim.uv.available_parallelism() * 2) or nil,

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
                "gzip",
                "matchit",
                -- "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
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

local M = {}

local field_map = {
    dependencies = false,

    on_setup = false,
    on_finalized = false,
    no_pending = false,
    lazy_load = false,

    no_auto_dependencies = false,
}

local lazy_info_field_map = {
    lazy = false,
    event = false,
    event_load_checker = false,
    very_lazy = false,
}

---@param dst lazy.PluginSpec
---@param src user.plugin.PluginSpec | string
local function copy_dependencies(dst, src)
    local src_dep = src.dependencies
    if not src_dep then return end

    if type(src_dep) == "string" then
        dst.dependencies = src_dep
    else
        local dependencies = {}
        for _, dep in pairs(src_dep) do
            if type(dep) == "string" then
                table.insert(dependencies, dep)
            else
                table.insert(dependencies, M.convert_sepc(dep))
            end
        end

        dst.dependencies = dependencies
    end
end

---@param spec user.plugin.PluginSpec | string
---@return lazy.PluginSpec
function M.convert_sepc(spec)
    ---@type lazy.PluginSpec
    local result = {}

    local spec_t = type(spec)

    if spec_t == "string" then
        result[1] = spec
    elseif spec_t == "table" then
        plugin_util.map_plugin_spec_fields(result, spec, field_map)

        copy_dependencies(result, spec)

        local lazy_info = spec.lazy_load
        if lazy_info then
            result.lazy = true
            plugin_util.map_plugin_spec_fields(result, lazy_info, lazy_info_field_map)

            if lazy_info.very_lazy then
                result.event = "VeryLazy"
            end
        end
    end

    return result;
end

-- Load plugin specifications into plugin manager.
---@param specs (user.plugin.PluginSpec | string)[]
---@param on_plugin_loaded fun(spec: user.plugin.PluginSpec | string)
function M.setup(specs, on_plugin_loaded)
    if is_bootstrap then return end

    local targets = {}

    for _, spec in ipairs(specs) do
        local converted = M.convert_sepc(spec)

        converted.config = function()
            on_plugin_loaded(spec)
        end

        table.insert(targets, converted)
    end

    manager.setup(targets, manager_config)
end

---@param spec (user.plugin.PluginSpec | string)[]
function M.load(spec)
    local full_name = type(spec) == "string" and spec or get_plugin_name_from_spec(spec)
    if not full_name then return end

    local segments = vim.split(full_name, "/")
    local name = segments[#segments]
    manager.load { plugins = { name } }
end

return M
