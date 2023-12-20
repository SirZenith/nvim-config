local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

user.theme.colorscheme = "palenightfall"

local function finalize(module)
    module.setup()
end

return wrap_with_module("palenightfall", finalize)
