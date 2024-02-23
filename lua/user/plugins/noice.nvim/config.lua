local user = require "user"
local config_const = require "user.config.constant"

user.plugin.noice = {
    __default = true,

    cmdline = {
        -- enables the Noice cmdline UI
        enabled = true,
        -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        view = "cmdline_popup",
        -- global options for the cmdline. See section on views
        opts = {},
        ---@type table<string, CmdlineFormat | false>
        format = {
            -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
            -- view: (default is cmdline view)
            -- opts: any options passed to the view
            -- icon_hl_group: optional hl_group for the icon
            -- title: set to anything or empty string to hide

            -- to disable a format, set to its value to `false`
            cmdline = {
                pattern = "^:",
                icon = "",
                lang = "vim",
                kind = "cmdline",
                view = "cmdline_popup",
            },
            search_down = {
                kind = "search",
                pattern = "^/",
                icon = " ",
                lang = "regex",
                view = "cmdline_popup",
            },
            search_up = {
                kind = "search",
                pattern = "^%?",
                icon = " ",
                lang = "regex",
                view = "cmdline_popup",
            },
            filter = {
                kind = "",
                pattern = "^:%s*!",
                icon = "$",
                lang = "bash",
                view = "cmdline_popup",
            },
            lua = {
                kind = "",
                pattern = { "^:%s*lua%s+" },
                icon = "",
                lang = "lua",
                view = "cmdline_popup",
            },
            help = {
                kind = "",
                pattern = {
                    "^:%s*he?l?p?%s+",
                    "^:%s*tab%s+he?l?p?%s+"
                },
                icon = "",
                view = "cmdline_popup",
            },
            -- Used by input()
            input = {
                kind = "",
                view = "cmdline_popup",
            },
        },
    },

    messages = {
        -- Enables the Noice messages UI
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true,

        -- default view for messages
        view = "cmdline",
        -- view for errors
        view_error = "cmdline",
        -- view for warnings
        view_warn = "cmdline",
        -- view for :messages
        view_history = "messages",
        -- view for search count messages. Set to `false` to disable
        view_search = "virtualtext",
    },

    popupmenu = {
        -- enables the Noice popupmenu UI
        enabled = false,

        -- backend to use to show regular cmdline completions
        ---@type "nui"|"cmp"
        backend = "cmp",

        -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
        -- set to `false` to disable icons
        ---@type NoicePopupmenuItemKind | false
        kind_icons = config_const.KIND_LABEL,
    },

    -- default options for require('noice').redirect
    -- see the section on Command Redirection
    ---@type NoiceRouteConfig
    redirect = {
        view = "popup",
        filter = { event = "msg_show" },
    },

    -- You can add any custom commands below that will be available with `:Noice command`
    ---@type table<string, NoiceCommand>
    commands = {
        -- :Noice history
        history = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
                any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = { "" } },
                    { event = "lsp",      kind = "message" },
                },
            },
            filter_opts = {},
        },
        -- :Noice last
        last = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = {
                any = {
                    { event = "notify" },
                    { error = true },
                    { warning = true },
                    { event = "msg_show", kind = { "" } },
                    { event = "lsp",      kind = "message" },
                },
            },
            filter_opts = { count = 1 },
        },
        -- :Noice warn
        warns = {
            -- options for the message history that you get with `:Noice`
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { warning = true },
            filter_opts = { reverse = true },
        },
        -- :Noice errors
        errors = {
            -- options for the message history that you get with `:Noice`
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
        },
    },

    notify = {
        -- Noice can take over `vim.notify`. All message can will be record in
        -- noice history with severe level attached.
        enabled = true,
        view = "cmdline",
    },

    lsp = {
        override = {
            -- override the default lsp markdown formatter with Noice
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = true,
            -- override cmp documentation with Noice (needs the other options to work)
            ["cmp.entry.get_documentation"] = true,
        },

        -- defaults for hover and signature help
        documentation = {
            view = "hover",
            ---@type NoiceViewOptions
            opts = {
                lang = "markdown",
                replace = true,
                render = "plain",
                format = { "{message}" },
                win_options = {
                    concealcursor = "n",
                    conceallevel = 3,
                },
            },
        },
        hover = {
            enabled = true,
            -- set to true to not show a message if hover is not available
            silent = true,
            -- when nil, use defaults from documentation
            view = nil,
            -- merged with defaults from documentation
            ---@type NoiceViewOptions
            opts = {},
        },
        message = {
            -- Messages shown by lsp servers
            enabled = true,
            view = "notify",
            opts = {},
        },
        progress = {
            enabled = false,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            --- @type NoiceFormat | string
            format = "lsp_progress",

            --- @type NoiceFormat | string
            format_done = "lsp_progress_done",
            -- frequency to update lsp progress message
            throttle = 1000 / 30,
            view = "mini",
        },
        signature = {
            enabled = true,
            auto_open = {
                enabled = true,
                -- Automatically show signature help when typing a trigger character from the LSP
                trigger = true,
                -- Will open signature help when jumping to Luasnip insert nodes
                luasnip = true,
                -- Debounce lsp signature help request by 50ms
                throttle = 100,
            },
            -- when nil, use defaults from documentation
            view = nil,
            -- merged with defaults from documentation
            ---@type NoiceViewOptions
            opts = {},
        },
    },

    markdown = {
        hover = {
            -- vim help links
            ["|(%S-)|"] = vim.cmd.help,
            -- markdown links
            ["%[.-%]%((%S-)%)"] = function(...)
                require "noice.util".open(...)
            end,
        },
        highlights = {
            ["|%S-|"] = "@text.reference",
            ["@%S+"] = "@parameter",
            ["^%s*(Parameters:)"] = "@text.title",
            ["^%s*(Return:)"] = "@text.title",
            ["^%s*(See also:)"] = "@text.title",
            ["{%S-}"] = "@parameter",
        },
    },

    health = {
        -- Disable if you don't want health checks to run
        checker = true,
    },

    smart_move = {
        -- noice tries to move out of the way of existing floating windows.
        -- you can disable this behaviour here
        enabled = false,
        -- add any filetypes here, that shouldn't trigger smart move.
        excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
    },

    ---@type NoicePresets
    presets = {
        -- Enable preset by setting it to true or a table. Table fields will
        -- override values preset config

        -- use a classic bottom cmdline for search
        bottom_search = false,
        -- position the cmdline and popupmenu together
        command_palette = false,
        -- long messages will be sent to a split
        long_message_to_split = false,
        -- enables an input dialog for inc-rename.nvim
        inc_rename = false,
        -- add a border to hover docs and signature help
        lsp_doc_border = false,
    },

    -- Duration between each Noice UI update. Unit: second.
    throttle = 1000 / 30,

    ---@type NoiceConfigViews
    ---@see section on views
    views = {
        cmdline = {
            timeout = 2000,
            position = {
                row = -1,
                col = 0,
            },
            size = {
                height = "auto",
                max_height = 5,
            },
        },
        cmdline_popup = {
            position = {
                row = 5,
                col = "50%",
            },
            size = {
                min_width = vim.o.columns > vim.o.lines * 2
                    and math.floor(vim.o.columns * 0.3)
                    or math.floor(vim.o.columns * 0.7),
                width = "auto",
                height = "auto",
            },
        },
    },

    ---@type NoiceRouteConfig[]
    --- @see section on routes
    routes = {
        {
            view = "cmdline",
            filter = {
                any = {
                    {
                        event = "msg_show",
                        kind = { "", "echo", "echomsg" },
                    },
                    { error = true },
                    { warning = true },
                    { event = "notify" },
                },

            },
            opts = {},
        },
    },

    ---@type table<string, NoiceFilter>
    --- @see section on statusline components
    status = {},

    ---@type NoiceFormatOptions
    --- @see section on formatting
    format = {},
}

return user.plugin.noice:with_wrap(function(value)
    require "noice".setup(value)
end)
