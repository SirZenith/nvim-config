local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

user.plugin.null_ls = {
    __new_entry = true,
    sources = {},
}

local function finalize(module)
    module.setup(user.plugin.null_ls())
end

return wrap_with_module("null-ls", finalize)
