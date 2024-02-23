local user = require "user"
local fs_util = require "user.util.fs"

local M = {}

-- ----------------------------------------------------------------------------

user.env = {
    __newentry = true,
    FIREFOX_PATH = "C:/Program Files/Mozilla Firefox/firefox.exe"
}

user.platform = {
    __newentry = true,
    windows = {
        nu_config_path = fs_util.path_join(user.env.APPDATA(), "nushell/config.nu"),
        nu_env_path = fs_util.path_join(user.env.APPDATA(), "nushell/env.nu"),
    },
}

user.autocmd = {
    __newentry = true,
    im_select = {
        check = "im-select.exe",
        on = "im-select.exe 2052",
        off = "im-select.exe 1033",
        isoff = function(im)
            return tonumber(im) == 1033
        end
    }
}

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
