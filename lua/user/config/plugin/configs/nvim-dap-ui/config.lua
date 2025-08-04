local user = require "user"

user.plugin.nvim_dap_ui = {
    __newentry = true,
    controls = {
        element = "breakpoints",
        enabled = true,
        icons = {
            disconnect = " ",
            pause = "",
            play = "",
            run_last = " ",
            step_back = " ",
            step_into = "",
            step_out = "",
            step_over = " ",
            terminate = " "
        },
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
        border = "single",
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    force_buffers = true,
    icons = {
        collapsed = " ",
        current_frame = " ",
        expanded = " ",
    },
    layouts = {
        {
            elements = {
                { id = "breakpoints", size = 0.25 },
                { id = "watches",     size = 0.25 },
                { id = "stacks",      size = 0.5 },
            },
            position = "left",
            size = 40,
        },
        {
            elements = {
                { id = "scopes", size = 1 },
            },
            position = "right",
            size = 40,
        }
        --[[ {
            elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 }
            },
            position = "bottom",
            size = 10
        }, ]]
    },
    mappings = {
        edit = "e",
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        repl = "r",
        toggle = "t",
    },
    render = {
        indent = 1,
        max_value_lines = 100,
    },
}

return user.plugin.nvim_dap_ui:with_wrap(function(value)
    local dap = require "dap"
    local dapui = require "dapui"

    dap.listeners.before.attach.dapui_config = dapui.open
    dap.listeners.before.launch.dapui_config = dapui.open
    dap.listeners.before.event_terminated.dapui_config = dapui.close
    dap.listeners.before.event_exited.dapui_config = dapui.close

    dapui.setup(value)
end)
