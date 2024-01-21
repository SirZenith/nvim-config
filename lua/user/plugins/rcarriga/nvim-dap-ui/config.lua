local user = require "user"

user.plugin.nvim_dap_ui = {
    __new_entry = true,
}

return function()
    local dap = require "dap"
    local dapui = require "dapui"

    dap.listeners.before.attach.dapui_config = dapui.open
    dap.listeners.before.launch.dapui_config = dapui.open
    dap.listeners.before.event_terminated.dapui_config = dapui.close
    dap.listeners.before.event_exited.dapui_config = dapui.close

    dapui.setup(user.plugin.nvim_dap_ui())
end
