return function()
    require "luasnip"

    local snip_utils = require "user.config.snippets.utils"
    local cmd_snip = require "user.config.snippets.cmd-snippet"

    snip_utils.load_autoload()
    snip_utils.init_lazy_load()
    snip_utils.init_conditional_load()
    cmd_snip.init()
end
