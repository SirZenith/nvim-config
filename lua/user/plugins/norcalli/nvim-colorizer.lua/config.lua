local wrap_with_module = require "user.utils".wrap_with_module

local function finalize(module)
    module.setup()
end

return wrap_with_module("colorizer", finalize)
