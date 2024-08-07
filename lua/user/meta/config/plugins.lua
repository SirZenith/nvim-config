---@class user.plugin.PluginSpec : lazy.PluginSpec
---@field before_load? fun() # function to be called before any plugin spec is passed to plugin loader
---@field after_finalization? fun() # function to be called after plugin config is finalized
---@field config_no_defer? boolean # finalize config module of plugin right after it's loaded
---@field config? fun(spec: user.plugin.PluginSpec) # cache value of `config` function before being overridden by plugin loader setup.
---@field old_config_func? fun(spec: user.plugin.PluginSpec) # cache value of `config` function before being overridden by plugin loader setup.
---@field autocmd_load_checker? fun(spec: user.plugin.PluginSpec, args: table): boolean

---@class user.plugin.UserConfigSpec : user.plugin.PluginSpec
---@field no_auto_dependencies? boolean