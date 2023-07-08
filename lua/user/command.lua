local utils = require "user.utils"
local ls = require "user.language-server"

local cmd = vim.api.nvim_create_user_command

---@param name string
---@param origin string
local function alias(name, origin)
    vim.cmd(("cnoreabbrev %s %s"):format(name, origin))
end

alias("Help", "tab help")
alias("tlsp", "Telescope")

-- ----------------------------------------------------------------------------

cmd("Reload", "source $MYVIMRC", {
    desc = "reload user config",
})

cmd("DumpConfigMeta", function()
    for k in pairs(package.loaded) do
        if k:starts_with("user") or k:starts_with("plugins") then
            package.loaded[k] = nil
        end
    end
    require "user".finalize()
    utils.dump_signature_metafile()
end, {
    desc = "dump user config metadata to file."
})

-- ----------------------------------------------------------------------------

cmd("LspDebugOn", function()
    ls.lsp_debug_on()
end, {
    desc = "turn on debug mode for LSP"
})

cmd("LspDebugOff", function()
    ls.lsp_debug_off()
end, {
    desc = "turn off debug mode for LSP"
})
