local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

user.plugin.prefab_cmp = {
    __new_entry = true,
    flavor = "cocos",
    path_map_func = function(path)
        return path
    end,
    prefab_loader = {},
}

local function finalize(module)
    module.setup(user.plugin.prefab_cmp())
end

return wrap_with_module("prefab-cmp", finalize)
