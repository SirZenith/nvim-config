local user = require "user"
local fs = require "user.utils.fs"

local css_root = fs.path_join(user.env.CONFIG_HOME(), "iamcco", "css")

user.option.g = {
    mkdp_open_to_the_world = true,
    -- mkdp_command_for_global = true,
    mkdp_filetypes = { "markdown", "markdown.pandoc" },
    mkdp_markdown_css = fs.path_join(css_root, "markdown.css"),
    mkdp_highlight_css = fs.path_join(css_root, "highlight.css"),
    mkdp_page_title = "${name}",
}
