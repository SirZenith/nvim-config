local util = require "user.util"

local validate = vim.validate
local import = util.import

local M = {}

-- Add server config to nvim-lspconfig
---@param ls_name string
---@param default_config table<string, any> # `default_config` field for config
---@param extra_opts? table<string, any> # all other fields of config that are optional
function M.add_lsp_config(ls_name, default_config, extra_opts)
    local lspconfigs_configs = import "lspconfig.configs"
    if not lspconfigs_configs then return end

    validate {
        cmd = { default_config.cmd, { 't', 'f' } },
        filetypes = { default_config.filetypes, 't' },
        root_dir = { default_config.root_dir, 'f' },
    }

    local config = vim.tbl_deep_extend("force", {}, extra_opts or {})
    config.default_config = default_config
    lspconfigs_configs[ls_name] = config
end

---@param config table
---@param dot_path string
---@param value any
function M.upsert_config_entry(config, dot_path, value)
    local segments = vim.split(dot_path, ".", { plain = true })
    local tail = table.remove(segments)

    local walker = config
    for _, seg in ipairs(segments) do
        local next_step = walker[seg]
        if not next_step then
            next_step = {}
            walker[seg] = next_step
        end
        walker = next_step
    end

    walker[tail] = value
end

---@param config table
---@param dot_path string
---@param value any
function M.append_config_entry(config, dot_path, value)
    if value == nil then
        return
    end

    local segments = vim.split(dot_path, ".", { plain = true })
    local tail = table.remove(segments)

    local walker = config
    for _, seg in ipairs(segments) do
        local next_step = walker[seg]
        if not next_step then
            next_step = {}
            walker[seg] = next_step
        end
        walker = next_step
    end

    local list = walker[tail]
    if not list then
        list = {}
        walker[tail] = list
    end

    list[#list + 1] = value
end

return M
