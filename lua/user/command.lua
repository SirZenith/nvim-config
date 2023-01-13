local ls = require "user.language-server"

vim.cmd "cnoreabbrev Help tab help"
vim.cmd "cnoreabbrev tlsp Telescope"

vim.api.nvim_create_user_command("Reload", "source $MYVIMRC", {
    desc = "reload user config",
})

vim.api.nvim_create_user_command(
    "LspDebugOn",
    function() ls.lsp_debug_on() end,
    { desc = "turn on debug mode for LSP" }
)
vim.api.nvim_create_user_command(
    "LspDebugOff",
    function() ls.lsp_debug_off() end,
    { desc = "turn off debug mode for LSP" }
)
