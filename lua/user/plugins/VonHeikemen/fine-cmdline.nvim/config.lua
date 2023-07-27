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
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    },
    hooks = {
        --[[ before_mount = function(input)
        end,
        after_mount = function(input)
        end, ]]
        set_keymaps = function(imap, feedkeys)
            -- All default key mapping except <Tab>, reserve that for completion
            imap('<Esc>', fn.close)
            imap('<C-c>', fn.close)
            imap('<Up>', fn.up_search_history)
            imap('<Down>', fn.down_search_history)
        end
    }
}

return function()
    require "user/plugins/VonHeikemen/fine-cmdline.nvim/keybinding"
    require("fine-cmdline").setup(user.plugin.fine_cmdline())
end
