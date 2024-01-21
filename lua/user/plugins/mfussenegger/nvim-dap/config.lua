local user = require "user"
local fs = require "user.utils.fs"

local dap_root = fs.path_join(user.env.APP_PATH(), "DAP")
local local_lua_root = fs.path_join(dap_root, "local-lua-debugger-vscode")

user.plugin.nvim_dap = {
    __new_entry = true,
    adapters = {
        firefox = {
            type = "executable",
            command = "node",
            args = {
                fs.path_join(dap_root, "vscode-firefox-debug", "dist", "adapter.bundle.js"),
            },
        },
        local_lua = {
            type = "executable",
            command = "node",
            args = {
                fs.path_join(local_lua_root, "extension", "debugAdapter.js"),
            },
            enrich_config = function(config, on_config)
                if not config.extensionPath then
                    config = vim.deepcopy(config)
                    -- 💀 If this is missing or wrong you'll see
                    -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
                    config.extensionPath = local_lua_root
                end
                on_config(config)
            end,
        },
    },
    configurations = {
        lua = {
            {
                name = "Current file (local-lua-dbg, lua)",
                type = "local_lua",
                request = "launch",
                cwd = "${workspaceFolder}",
                program = {
                    lua = "lua",
                    file = "${file}",
                },
                args = {},
            },
        },
        typescript = {
            {
                name = "Debug with Firefox",
                type = "firefox",
                request = "launch",
                reAttach = true,
                url = "http://localhost:3000",
                webRoot = "${workspaceFolder}",
                firefoxExecutable = "",
            },
        }
    },
    signs = {
        DapBreakpoint          = { text = "●", texthl = "DapBreakpoint" },
        DapBreakpointCondition = { text = "●", texthl = "DapBreakpointCondition" },
        DapLogPoint            = { text = "●", texthl = "DapLogPoint" },
        DapStopped             = { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine" },
        DapBreakpointRejected  = { text = "●", texthl = "DapBreakpointRejected" },
    }
}

return function()
    local dap = require "dap"

    local config = user.plugin.nvim_dap
    if not config then
        vim.notify("no config entry found for nvim-dap", vim.log.levels.WARN)
        return
    end

    -- update firefox config
    local ts_configs = config.configurations.typescript()
    for _, cfg in ipairs(ts_configs) do
        if cfg.firefoxExecutable == "" then
            cfg.firefoxExecutable = user.env.FIREFOX_PATH()
        end
    end
    config.configurations.typescript = ts_configs

    for key, value in config.adapters:pairs() do
        dap.adapters[key] = value
    end

    for key, value in config.configurations:pairs() do
        dap.configurations[key] = value
    end

    for name, cfg in config.signs:pairs() do
        vim.fn.sign_define(name, cfg)
    end
end
