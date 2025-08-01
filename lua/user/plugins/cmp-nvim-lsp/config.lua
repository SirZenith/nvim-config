local user = require "user"

return function()
    local cmp_nvim_lsp = require "cmp_nvim_lsp"

    user.lsp.capabilities_list:append(cmp_nvim_lsp.default_capabilities())
end
