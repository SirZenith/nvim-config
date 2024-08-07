---@meta

---@class lazy.PluginSpec
---@field [1] string # URL to plugin
---@field dir string? # path to local plugin
---@field url string? # custom git URL to plugin host
---@field name? string # Specifies an alias under which to install the plugin
--
---@field dev? boolean # If true, a local directory will be used instead
---@field enabled? boolean # Is the plugins activated
--
---@field dependencies? string | (string | lazy.PluginSpec)[] # Specifies plugin dependencies. When local plugins is specified as dependency, plugin spec value with `dir` field should be used.
---@field priority? number # useful for non-lazy plugins, higher number means higher priority, default is 50
--
---@field init? fun() # This function gets called on plugin startup
---@field opts? table # Config table that will be passed to config function
---@field config? fun(plugin: lazy.PluginSpec, opts: table) | boolean # Executed when plugin loads.
---@field main? string # main module name of plugin
---@field build? string | string[] | fun() # Executed when plugin is installed or updated
--
---@field branch? string # Specifies a git branch to use
---@field tag? string # Specifies a git tag to use. Supports '*' for "latest tag"
---@field commit? string # Specifies a git commit to use
---@field version? string | false # version to use from the repository
---@field pin? boolean # if true, this plugin will not be updated by Lazy
---@field submodules boolean? # if false, submodules will be ignored, default to true,
--
---@field installer? function # Specifies custom installer. See "custom installers" below.
---@field updater? function # Specifies custom updater. See "custom installers" below.
---@field after? string | string[] # Specifies plugins to load before this plugin. See "sequencing" below
---@field rtp? string # Specifies a subdirectory of the plugin to add to runtimepath.
---@field bufread? boolean # Manually specifying if a plugin needs BufRead after being loaded
---@field lock? boolean # Skip updating this plugin in updates/syncs. Still cleans.
---@field rocks? string | string[] # Specifies Luarocks dependencies for the plugin
---@field setup? string | function # implies `opt = true` Specifies code to run before this plugin is loaded even the plugin is waiting for other conditions.
--
---@field lazy? boolean # If true, plugin would only be loaded when it gets `require`d, or lazy loading handler is triggered
---@field cond? string | function | (string | function)[] # Specifies a conditional test to load this plugin
---@field event? string | string[] # Specifies autocommand events which load this plugin.
---@field ft? string | string[] # Specifies filetypes which load this plugin.
---@field cmd? string | string[] # Specifies commands which load this plugin. Can be an autocmd pattern.
---@field keys? string | string[] # Specifies maps which load this plugin. See "Keybindings".
---@field module? string | string[] # Specifies Lua module names for require. When requiring a string which starts with one of these module names, the plugin will be loaded.
