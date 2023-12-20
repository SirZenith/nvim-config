local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

local check_exclude = function(filepath)
    local exclude = user.plugin.telescope_nvim.preview_exclude()
    if type(exclude) ~= "table" then
        return false;
    end

    for _, v in ipairs(exclude) do
        if filepath:match(v) then
            return true
        end
    end

    return false
end

local previewer_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    if opts.use_ft_detect == nil then
        opts.use_ft_detect = true
    end

    if opts.use_ft_detect then
        opts.use_ft_detect = not check_exclude(filepath);
    end

    local previewers = require "telescope.previewers"
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

user.plugin.telescope_nvim = {
    __new_entry = true,
    -- turn off syntax highlighting for certain file name pattern.
    preview_exclude = { ".*%.meta", ".*%.prefab" },
    config = {
        defaults = {
            buffer_previewer_maker = previewer_maker,
        },
    }
}

local function finalize(module)
    module.setup(user.plugin.telescope_nvim.config())
end

return wrap_with_module("telescope", finalize)
