local set = vim.keymap.set

return function()
    local api_ui = require "mongosh-nvim.api.ui"

    set("n", "<leader>mb", api_ui.toggle_db_sidebar)
end
