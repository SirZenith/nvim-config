local M = {}

M.settings = {
    ["rust-analyzer"] = {
        cargo = {
            buildScripts = {
                enable = true,
            },
        },
        imports = {
            granularity = {
                group = "module",
            },
            prefix = "self",
        },
        procMacro = {
            enable = true
        },
    }
}

return M
