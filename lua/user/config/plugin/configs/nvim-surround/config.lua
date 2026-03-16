local user = require "user"

user.plugin.nvim_surround = {
    __newentry = true,
    -- Built-in delimiters include:
    -- - (), [], {}, <>, '', "", triggered by either side of delimiter.
    -- - HTML tags, triggered by `t` or `T`, e.g. `ysiwt`, tag name is given by
    --   input box.
    -- - Function call, triggered by `f`, e.g. `ysiwf`, function name is given
    --   by input box.


}

user.option.g = {
    nvim_surround_no_normal_mappings = true,
    nvim_surround_no_visual_mappings = true,
    nvim_surround_no_insert_mappings = true,
}

return user.plugin.nvim_surround:with_wrap(function(value)
    require "nvim-surround".setup(value)
end)
