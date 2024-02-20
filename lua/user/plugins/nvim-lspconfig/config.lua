local user = require "user"
local lsp_util = require "user.utils.lsp"

return function()
    for name, config in user.lsp.extra_server:pairs() do
        lsp_util.add_lsp_config(name, config)
    end
end
