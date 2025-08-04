return function()
    local dap = require "dap"
    -- local widgets = require "dap.ui.widgets"

    local kset = vim.keymap.set

    kset("n", "<F5>", dap.continue)
    kset("n", "<F6>", dap.step_over)
    kset("n", "<F7>", dap.step_into)
    kset("n", "<F8>", dap.step_out)

    kset("n", "<Leader>db", dap.toggle_breakpoint)
    -- kset("n", "<Leader>B", dap.set_breakpoint)
    kset("n", "<Leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end)

    -- kset("n", "<Leader>dr", dap.repl.open)
    -- kset("n", "<Leader>dl", dap.run_last)

    -- kset({ "n", "v" }, "<Leader>dh", widgets.hover)
    -- kset({ "n", "v" }, "<Leader>dp", widgets.preview)
    --[[ kset("n", "<Leader>df", function()
        widgets.centered_float(widgets.frames)
    end) ]]
    --[[ kset("n", "<Leader>ds", function()
        widgets.centered_float(widgets.scopes)
    end) ]]
end

