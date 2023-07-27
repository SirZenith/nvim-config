local user = require "user"
local fineline = require "fine-cmdline"

local fn = fineline.fn

user.plugin.fine_cmdline = {
    __new_entry = true,
    cmdline = {
        enable_keymaps = true,
        smart_history = true,
        prompt = ": "
    },
    popup = {
        buf_options = {
            filetype = "FineCmdlinePrompt"
        },
        position = {
            row = "20%",
            col = "50%",
        },
        size = {
            width = "38%",
        },
        border = {
            style = "rounded",
        },
        win_options = {
            winhighlight = "Normal:FineCmdLineWin,FloatBorder:FineCmdLineBorder" ,
        },
    },
    hooks = {
        before_mount = function(input)
        end,
        after_mount = function(input)
            local opt = { buffer = 0 }
            local set = vim.keymap.set
            set("i", "<Esc>", fn.close, opt)
            set("i", "<C-c>", fn.close, opt)
            set("i", "<Up>", fn.up_search_history, opt)
            set("i", "<Down>", fn.down_search_history, opt)
        end,
        set_keymaps = function(imap, feedkeys)
        end,
    }
}

return function()
    require "user/plugins/VonHeikemen/fine-cmdline.nvim/keybinding"
    require("fine-cmdline").setup(user.plugin.fine_cmdline())
end
