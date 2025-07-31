local user = require "user"
local config_entry = require "user.base.config_entry"
local util = require "user.util"
local fs_util = require "user.util.fs"

local api = vim.api
local cmd = api.nvim_create_user_command
local import = util.import

-- ----------------------------------------------------------------------------

user.command = {
    __newentry = true,

    ---@type table<string, string>
    alias_map = {
        thelp = "tab help",
        tlsp = "Telescope",
    },
}

-- ----------------------------------------------------------------------------

cmd("Reload", "source $MYVIMRC", {
    desc = "reload user config",
})

cmd("ShowUserConfig", function()
    local bufnr = api.nvim_create_buf(false, true)

    vim.cmd.vsp()
    local winnr = api.nvim_get_current_win()
    api.nvim_win_set_buf(winnr, bufnr)

    local content = tostring(user)
    local lines = vim.split(content, "\n")
    api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)

    local bo = vim.bo[bufnr]
    bo.filetype = "lua"
    bo.modifiable = false
end, {
    desc = "show current value of user config entry in buffer.",
})

cmd("DumpConfigMeta", function()
    local plugin_specs = import "user.config.plugin.spec"
    local plugin_loader = import "user.config.plugin.loader"
    plugin_loader.load_all_plugin_config(plugin_specs)

    local filepath = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "meta", "user_config.lua")
    config_entry.dump_signature(user --[[@as user.config.ConfigEntry]], filepath)
end, {
    desc = "dump user config metadata to file."
})

cmd("ToTab", function()
    local buf = api.nvim_win_get_buf(0)
    if buf <= 0 then return end

    local old_win = api.nvim_get_current_win()

    vim.cmd "tabnew"
    api.nvim_win_set_buf(0, buf)

    api.nvim_win_close(old_win, false)
end, {
    desc = "extract current buffer into new tab."
})

cmd("CloseAllBuffer", function()
    vim.cmd "wa"

    local bufs = api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        api.nvim_buf_delete(buf, {})
    end
end, {
    desc = "save & delete all buffers",
})

cmd("AutoFormatOff", function()
    require "conform".setup {
        format_after_save = false,
    }
end, {
    desc = "turn off auto formatting after save",
})

cmd("AutoFormatOn", function()
    require "conform".setup {
        format_after_save = true,
    }
end, {
    desc = "turn on auto formatting after save",
})

-- ----------------------------------------------------------------------------

return function()
    for name, origin in user.command.alias_map:pairs() do
        vim.cmd(("cnoreabbrev %s %s"):format(name, origin))
    end
end
