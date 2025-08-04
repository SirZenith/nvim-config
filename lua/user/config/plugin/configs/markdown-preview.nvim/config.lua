local user = require "user"
local fs_util = require "user.util.fs"

local css_root = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "plugins", "css")

user.plugin.markdown_preview_nvim.option.g = {
    __newentry = true,

    mkdp_open_to_the_world = true,
    -- mkdp_command_for_global = true,
    mkdp_filetypes = { "markdown", "markdown.pandoc" },
    mkdp_markdown_css = fs_util.path_join(css_root, "markdown.css"),
    mkdp_highlight_css = fs_util.path_join(css_root, "highlight.css"),
    mkdp_page_title = "${name}",
}

return user.plugin.markdown_preview_nvim:with_wrap(function(value)
    for k, v in pairs(value.option.g) do
        vim.g[k] = v
    end
end)
