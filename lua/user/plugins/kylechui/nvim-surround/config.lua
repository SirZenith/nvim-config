local user = require "user"

user.plugin.nvim_surround = {
    __new_entry = true,
    keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
        change_line = "cS",
    },
}

return function()
    require "nvim-surround".setup(user.plugin.nvim_surround())
end
