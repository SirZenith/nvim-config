local user = require "user"

user.plugin.prefab_cmp = {
    __new_entry = true,
    flavor = "cocos",
    path_map_func = function(path)
        return path
    end,
    prefab_loader = {},
}

return function()
    require "prefab-cmp".setup(user.plugin.prefab_cmp())
end
