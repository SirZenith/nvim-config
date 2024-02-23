local user = require "user"
local fs_util = require "user.util.fs"

local M = {}

M.im_select = {
    __default = true,
    check = "im-select.exe",
    on = "im-select.exe 2052",
    off = "im-select.exe 1033",
    isoff = function(im)
        return tonumber(im) == 1033
    end
}

-- ----------------------------------------------------------------------------

user.env = {
    FIREFOX_PATH = "C:/Program Files/Mozilla Firefox/firefox.exe"
}

user.platform.windows = {
    __default = true,
    nu_config_path = fs_util.path_join(user.env.HOME(), [[AppData\Roaming\nushell\config.nu]]),
    nu_env_path = fs_util.path_join(user.env.HOME(), [[AppData\Roaming\nushell\env.nu]]),
}
user.platform.im_select = M.im_select

-- ----------------------------------------------------------------------------

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
