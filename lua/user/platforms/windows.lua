local user = require "user"
local fs = require "user.utils.fs"

user.platform.windows = {
    nu_config_path = fs.path_join(vim.env.HOME, [[AppData\Roaming\nushell\config.nu]]),
    nu_env_path = fs.path_join(vim.env.HOME, [[AppData\Roaming\nushell\env.nu]]),
}

return function()
    local shellcmdflag = ("--config %s --env-config %s -c"):format(
        user.platform.windows.nu_config_path(),
        user.platform.windows.nu_env_path()
    )

    vim.go.shellcmdflag = shellcmdflag
end
