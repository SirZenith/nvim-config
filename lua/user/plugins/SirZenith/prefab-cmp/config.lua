local user = require "user"
local prefab_cmp = require "prefab-cmp"

user.plugin.prefab_cmp = {
    __new_entry = true,
    flavor = "cocos",
    path_map_func = function(path)
        return path
    end,
    prefab_loader = {},
}

return function()
    prefab_cmp.setup(user.plugin.prefab_cmp())
end
