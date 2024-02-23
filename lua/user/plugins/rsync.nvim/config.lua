local user = require "user"

user.plugin.rsync_nvim = {
    __newentry = true,

    -- triggers `RsyncUp` when fugitive thinks something might have changed in the repo.
    fugitive_sync = false,
    -- triggers `RsyncUp` when you save a file.
    sync_on_save = true,
    -- the path to the project configuration
    project_config_path = ".nvim/rsync.toml",
    -- called when the rsync command exits, provides the exit code and the used command
    ---@type fun(code: integer, command: string)
    ---@diagnostic disable-next-line: unused-local
    on_exit = function(code, command)
    end,
    -- called when the rsync command prints to stderr, provides the data and the used command
    ---@type fun(code: integer, command: string)
    ---@diagnostic disable-next-line: unused-local
    on_stderr = function(data, command)
    end,
}

return user.plugin.rsync_nvim:wtih_wrap(function(value)
    require "rsync".setup(value)
end)
