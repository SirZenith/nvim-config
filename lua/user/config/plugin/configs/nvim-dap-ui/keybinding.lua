return function()
    local dapui = require "dapui"

    local kset = vim.keymap.set

    kset("n", "<Leader>dr", function()
        dapui.float_element("repl", {
            width = 80,
            height = 40,
            enter = true,
            position = "center",
        })
    end)

    kset("n", "<Leader>dc", function()
        dapui.float_element("console", {
            width = 80,
            height = 40,
            enter = true,
            position = "center",
        })
    end)

    kset({ "n", "v" }, "<Leader>dh", dapui.eval)
end
