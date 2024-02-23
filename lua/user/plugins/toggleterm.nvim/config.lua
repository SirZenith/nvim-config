local user = require "user"

---@class user.plugin.TerminalFloatOpts
---@field border "none" | "single" | "double" | "rounded" | "solid" | "shadow" | "curved" | string[]  # Border accepts all value supported by "nvim_open_win", with an additional "curved" type, which is implemented by this plugin.
---@field width number | user.plugin.TerminalSizeFunc,
---@field height number | user.plugin.TerminalSizeFunc
---@field row number | user.plugin.TerminalSizeFunc
---@field col number | user.plugin.TerminalSizeFunc
---@field winblend number
---@field zindex number
---@field title_pos "left" | "center" | "right" # position of the title of the floating window

---@class user.plugin.Terminal
---@field name string
---@field direction "horizontal" | "vertical"
---@field float_opts user.plugin.TerminalFloatOpts

---@alias user.plugin.TerminalSizeFunc fun(term: user.plugin.Terminal): number

user.plugin.toggleterm = {
    __newentry = true,

    -- Default shell of terminal.
    ---@type string | fun(): string
    shell = user.general.option.go.shell(),

    ---@type string
    open_mapping = "<F12>",
    -- If `open_mapping` should also be set for insert mode.
    ---@type boolean
    insert_mappings = true,
    -- If `open_mapping` should also be set for terminal mode.
    ---@type boolean
    terminal_mappings = true,

    ---@type boolean
    start_in_insert = true,
    -- close the terminal window when the process exits
    ---@type boolean
    close_on_exit = true,

    ---@type boolean
    persist_size = true,
    -- Remeber last used mode in terminal buffer until next time it gets opened.
    persist_mode = false,

    -- When neovim changes CWD, automatically change PWD of terminal on next
    -- time it gets opened.
    autochdir = false,
    -- Automatically scroll to the bottom on terminal output.
    ---@type boolean
    auto_scroll = true,

    -- ------------------------------------------------------------------------
    -- Appearance

    -- Highlight group value for terminal buffer, keys are group name, values
    -- are config value of that group. Any highlight groups listed here will
    -- be set in terminal buffer
    ---@type table<string, table>
    highlights = {},
    ---@type "vertical" | "horizontal" | "tab" | "float"
    direction = "float",
    -- hide the number column in toggleterm buffers
    ---@type boolean
    hide_numbers = true,
    shade_filetypes = {},
    -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    shade_terminals = true,
    -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
    ---@type number
    shading_factor = -30,

    -- Split size of horizontal or vertical terminal window.
    ---@type number | user.plugin.TerminalSizeFunc
    size = function(term)
        vim.print(term)
        if term.direction == "horizontal" then
            return 15
        end
        return math.floor(vim.o.columns * 0.4)
    end,
    -- Winbar setting only applies to non-floating terminal window.
    winbar = {
        enabled = true,
        ---@type fun(term: user.plugin.Terminal): string
        name_formatter = function(term)
            return term.name
        end
    },
    -- Appearance for `float` directional terminal window.
    ---@type user.plugin.TerminalFloatOpts
    float_opts = {
        border = "rounded",

        width = function()
            return math.floor(vim.o.columns * 0.6)
        end,
        height = function()
            return math.floor(vim.o.lines * 0.7)
        end,

        row = function(term)
            local opts = term.float_opts

            local height = opts.height
            if type(height) == "function" then
                height = height(term)
            end

            local row = (vim.o.lines - height) / 2

            return math.floor(row)
        end,
        col = function(term)
            local opts = term.float_opts

            local width = opts.width
            if type(width) == "function" then
                width = width(term)
            end

            local col = (vim.o.columns - width) / 2

            return math.floor(col)
        end,

        winblend = 3,
        zindex = 1,

        title_pos = "center",
    },

    -- ------------------------------------------------------------------------
    -- Hook

    -- function to run when the terminal is first created
    ---@type fun(t: user.plugin.Terminal)
    on_create = nil,
    -- function to run when the terminal opens
    ---@type fun(t: user.plugin.Terminal)
    on_open = nil,
    -- function to run when the terminal closes
    ---@type fun(t: user.plugin.Terminal)
    on_close = nil,
    -- callback for processing output on stdout
    ---@type fun(t: user.plugin.Terminal, job: number, data: string[], name: string)
    on_stdout = nil,
    -- callback for processing output on stderr
    ---@type fun(t: user.plugin.Terminal, job: number, data: string[], name: string)
    on_stderr = nil,
    -- function to run when terminal process exits
    ---@type fun(t: user.plugin.Terminal, job: number, exit_code: number, name: string)
    on_exit = nil,
}

return user.plugin.toggleterm:with_wrap(function(value)
    require "toggleterm".setup(value)
end)
