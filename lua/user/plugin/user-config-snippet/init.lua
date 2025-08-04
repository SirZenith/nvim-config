local command = require "user.config.snippet.command"
local loader = require "user.config.snippet.loader"

command.init()

loader.load_autoload()
loader.init_lazy_load()
loader.init_conditional_load()
