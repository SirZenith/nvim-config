local user = require "user"

user.nvim_tree = {
    respect_buf_cwd = false,
    create_in_closed_folder = false,
    disable_netrw = false,
    hijack_netrw = true,
    hijack_cursor = false,
    ignore_buffer_on_setup = false,
    ignore_ft_on_setup = {},
    auto_reload_on_write = true,
    open_on_tab = false,
    update_cwd = true,
    hijack_unnamed_buffer_when_opening = false,
    hijack_directories = {
        enable = true,
        auto_open = true,
    },
    diagnostics = {
        enable = true,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        }
    },
    renderer = {
        group_empty = true,
        highlight_opened_files = "none",
        highlight_git = true,
        icons = {
            padding = " ",
            show = {
                git = true,
                folder = true,
                file = true,
                folder_arrow = true,
            },
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    unstaged = "✗",
                    staged = "✓",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "★",
                    deleted = "",
                    ignored = "◌"
                },
                folder = {
                    arrow_open = "",
                    arrow_closed = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
            },
        },
        special_files = { ["README.md"] = 1, Makefile = 1, MAKEFILE = 1 },
    },
    update_focused_file = {
        enable      = false,
        update_cwd  = false,
        ignore_list = {}
    },
    system_open = {
        cmd  = nil,
        args = {}
    },
    filters = {
        dotfiles = true,
        custom = {
            "**/*.meta"
        }
    },
    git = {
        -- enable = vim.env.PLATFORM_MARK ~= "windows",
        enable = true,
        ignore = false,
        timeout = 200,
    },
    view = {
        width = 30,
        -- height = 30,
        hide_root_folder = false,
        side = 'left',
        preserve_window_proportions = false,
        mappings = {
            custom_only = false,
            list = {}
        },
        number = false,
        relativenumber = false,
        signcolumn = "yes"
    },
    trash = {
        cmd = "trash",
        require_confirm = true
    },
    actions = {
        change_dir = {
            enable = true,
            global = false,
        },
        open_file = {
            quit_on_open = true,
            resize_window = false,
            window_picker = {
                enable = false,
                chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                exclude = {
                    filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", },
                    buftype  = { "nofile", "terminal", "help", },
                }
            }
        }
    },
    log = {
        enable = false,
        types = {
            all = false,
            config = false,
            git = false,
        },
    },
}

return function()
    local group_id = vim.api.nvim_create_augroup("user.nvim_tree", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group_id,
        callback = function()
            require("nvim-tree.api").tree.open()
        end,
    })

    vim.cmd "highlight NvimTreeFolderIcon guibg=blue"
    require "nvim-tree".setup(user.nvim_tree())
end
