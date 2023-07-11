local user = require "user"
local fs = require "user.utils.fs"

local M = {}

M.im_select = {
    check = "im-select.exe",
    on = "im-select.exe 2052",
    off = "im-select.exe 1033",
    isoff = function(im)
        return tonumber(im) == 1033
    end
}

-- ----------------------------------------------------------------------------

user.platform.windows = {
    __new_entry = true,
    nu_config_path = fs.path_join(vim.env.HOME, [[AppData\Roaming\nushell\config.nu]]),
    nu_env_path = fs.path_join(vim.env.HOME, [[AppData\Roaming\nushell\env.nu]]),
}
user.general.im_select = M.im_select

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
