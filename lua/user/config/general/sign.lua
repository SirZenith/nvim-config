local sign = vim.tbl_extend('force', {
    -- LSP diagnostics
    DiagnosticSignError = { text = "", texthl = "DiagnosticSignError" },
    DiagnosticSignWarn = { text = "", texthl = "DiagnosticSignWarn" },
    DiagnosticSignInfo = { text = "", texthl = "DiagnosticSignInfo" },
    DiagnosticSignHint = { text = "", texthl = "DiagnosticSignHint" },
}, {
    -- nvim-dap
    DapBreakpoint          = { text = "●", texthl = "DapBreakpoint" },
    DapBreakpointCondition = { text = "●", texthl = "DapBreakpointCondition" },
    DapLogPoint            = { text = "●", texthl = "DapLogPoint" },
    DapStopped             = { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine" },
    DapBreakpointRejected  = { text = "●", texthl = "DapBreakpointRejected" },
})

return sign
