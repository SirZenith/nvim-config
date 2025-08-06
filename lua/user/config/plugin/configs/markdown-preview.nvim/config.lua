local user = require "user"

local css_root = vim.fs.joinpath(user.env.USER_RUNTIME_PATH(), "user", "plugins", "css")

user.plugin.markdown_preview_nvim.option.g = {
    __newentry = true,

    mkdp_open_to_the_world = true,
    -- mkdp_command_for_global = true,
    mkdp_filetypes = { "markdown", "markdown.pandoc" },
    mkdp_markdown_css = vim.fs.joinpath(css_root, "markdown.css"),
    mkdp_highlight_css = vim.fs.joinpath(css_root, "highlight.css"),
    mkdp_page_title = "${name}",
}

return user.plugin.markdown_preview_nvim:with_wrap(function(value)
    for k, v in pairs(value.option.g) do
        vim.g[k] = v
    end
end)
