local user = require "user"

-- return false when nvim is started with name of file as arguments.
local function check_need_open_tree()
    local output = vim.api.nvim_command_output "args"
    local cur_file = output:match("%[(.+)%]")
    return vim.fn.filereadable(cur_file) ~= 1
end

local function try_open_tree()
    if check_need_open_tree() then
        require("nvim-tree.api").tree.open()
    end
end

user.plugin.nvim_tree = {
    __new_entry = true,
    respect_buf_cwd = false,
    create_in_closed_folder = false,
    disable_netrw = false,
    hijack_netrw = true,
    hijack_cursor = false,
    auto_reload_on_write = true,
    open_on_tab = false,
    update_cwd = true,
    hijack_unnamed_buffer_when_opening = false,
    hijack_directories = {
        enable = false,
        auto_open = false,
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
        group_empty = false,
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
            "**/*\\.meta$"
        }
    },
    git = {
        enable = true,
        ignore = false,
        timeout = 1000,
    },
    view = {
        width = 30,
        -- height = 30,
        side = 'left',
        preserve_window_proportions = false,
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
    local nvim_tree = require "nvim-tree"

    nvim_tree.setup(user.plugin.nvim_tree())
end
