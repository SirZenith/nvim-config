local user = require "user"
local prefab_cmp = require "prefab-cmp"

user.plugin.prefab_cmp = {
    __new_entry = true,
    flavor = "cocos",
    path_map_func = function(_)
        return "not exists"
    end,
}

return function()
    prefab_cmp.setup {
        flavor = user.plugin.prefab_cmp.flavor(),
        path_map_func = user.plugin.prefab_cmp.path_map_func(),
    }
end
