local user = require "user"

user.plugin.nvim_eslint = {
    __newentry = true,

    -- Toggle debug mode for ESLint language server, see debugging part
    debug = false,

    -- The settings send to ESLint LSP. See below part for details.
    settings = {
        codeActionOnSave = { mode = 'problems' },
        format = {
            enable = false,
        },
        quiet = false,
        onIgnoredFiles = 'off',
        options = {},
        rulesCustomizations = {},
        run = 'onSave',
        problems = { shortenToSingleLine = false },
        workingDirectory = { mode = 'location' },
    }
}

return user.plugin.nvim_eslint:with_wrap(function(value)
    require "nvim-eslint".setup(value)
end)
