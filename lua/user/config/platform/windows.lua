local user = require "user"
local log = require "user.util.log"

local M = {}

-- ----------------------------------------------------------------------------

local im_select_path = vim.env.IM_SELECT_PATH
-- local weasel_server_path = vim.env.WEASEL_SERVER_PATH
local weasel_server_path = nil

user.env = {
    __newentry = true,
    FIREFOX_PATH = "C:/Program Files/Mozilla Firefox/firefox.exe"
}

user.platform = {
    __newentry = true,
    windows = {
        nu_config_path = vim.fs.joinpath(user.env.APPDATA(), "nushell/config.nu"),
        nu_env_path = vim.fs.joinpath(user.env.APPDATA(), "nushell/env.nu"),
    },
}

if weasel_server_path then
    user.autocmd.im_select = {
        __newentry = true,
        check = "echo place_holder",
        on = weasel_server_path .. " /nascii",
        off = weasel_server_path .. " /ascii",
        isoff = function(_)
            return false
        end
    }
elseif im_select_path then
    user.autocmd.im_select = {
        __newentry = true,
        check = im_select_path,
        on = im_select_path .. " 2052",
        off = im_select_path .. " 1033",
        isoff = function(im)
            return tonumber(im) == 1033
        end
    }
else
    log.warn("neither WeaselServer.exe nor im-select.exe is found in environment")
end

-- ----------------------------------------------------------------------------

M.windows = true

function M.finalize()
    --[[
    local shellcmdflag = ("--config %s --env-config %s -c"):format(
        user.platform.windows.nu_config_path(),
        user.platform.windows.nu_env_path()
    )
    vim.go.shellcmdflag = shellcmdflag
    ]]
end

return M
