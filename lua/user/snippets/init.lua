local import = require "user.utils".import

if not import "luasnip" then
    vim.notify("snippet initialization failed")
    return
end

local snip_utils = require "user.snippets.utils"

return function()
    snip_utils.load_autoload()
    snip_utils.init_lazy_load()
    snip_utils.init_conditional_load()
end
