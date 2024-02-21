local user = require "user"

user.plugin.prefab_cmp = {
    __new_entry = true,
    flavor = "cocos",
    path_map_func = function(path)
        return path
    end,
    prefab_loader = {},
}

return user.plugin.prefab_cmp:with_wrap(function(value)
    require "prefab-cmp".setup(value)
end)
