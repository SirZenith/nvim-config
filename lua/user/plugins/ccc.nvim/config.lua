local user = require "user"

---@alias user.plugin.ccc_nvim.HLMode "fg" | "foreground" | "bg" | "background"
---@alias user.plugin.ccc_nvim.ShowMode "auto" | "show" | "hide"

user.plugin.ccc_nvim = {
    __default = true,
    ---@type string # hex
    default_color = "#000000",
    ---@type string
    bar_char = "█",
    ---@type string
    point_char = "▢",
    ---@type string # hex
    point_color = "",
    ---@type boolean
    empty_point_bg = true,
    ---@type string # hex
    point_color_on_dark = "#ffffff",
    ---@type string # hex
    point_color_on_light = "#000000",
    ---@type integer
    bar_len = 30,
    ---@type table
    win_opts = {
        relative = "cursor",
        row = 1,
        col = 1,
        style = "minimal",
        border = "rounded",
    },
    ---@type boolean
    auto_close = true,
    ---@type boolean
    preserve = false,
    ---@type boolean
    save_on_quit = false,
    ---@type user.plugin.ccc_nvim.ShowMode
    alpha_show = "auto",

    ---@type user.plugin.ccc_nvim.HLMode
    highlight_mode = "bg",
    ---@type table
    highlighter = {
        ---@type boolean
        auto_enable = false,
        ---@type integer
        max_byte = 100 * 1024, -- 100 KB
        ---@type string[]
        filetypes = {},
        ---@type string[]
        excludes = {},
        ---@type boolean
        lsp = true,
        ---@type boolean
        update_insert = true,
    },
}

return user.plugin.ccc_nvim:with_wrap(function(value)
    require "ccc".setup(value)
end)
