local user = require "user"
local fs = require "user.utils.fs"

local onedrive = vim.env.ONEDRIVE or fs.path_join(vim.env.HOME, "OneDrive")
local css_root = fs.path_join(onedrive, "Documents", "云端文档", "样式表", "markdown-preview.nvim")

user.g = {
    mkdp_open_to_the_world = true,
    -- mkdp_command_for_global = true,
    mkdp_filetypes = { "markdown", "markdown.pandoc" },
    mkdp_markdown_css = fs.path_join(css_root, "markdown.css"),
    mkdp_highlight_css = fs.path_join(css_root, "highlight.css"),
    mkdp_page_title = "${name}",
}

