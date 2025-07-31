local user = require "user"

user.diagnostics = {
    __newentry = true,
    signs = {
        -- LSP diagnostics
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
            -- nvim-dap
            -- DapBreakpoint = { text = "●", texthl = "DapBreakpoint" },
            -- DapBreakpointCondition = { text = "●", texthl = "DapBreakpointCondition" },
            -- DapLogPoint = { text = "●", texthl = "DapLogPoint" },
            -- DapStopped = { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine" },
            -- DapBreakpointRejected = { text = "●", texthl = "DapBreakpointRejected" },
        },
        --[[ linehl = {
            [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
        }, ]]
    }
}

return function()
    vim.diagnostic.config(user.diagnostics())
end
