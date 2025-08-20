local fs_util = require "user.util.fs"

local M = {}

-- Generate namespace module name by file name.
---@return string
function M.get_namespace_name_from_file_name()
    local file_name = vim.api.nvim_buf_get_name(0)
    file_name = fs_util.remove_ext(file_name)
    file_name = vim.fs.basename(file_name) or ""
    return file_name:upper()
end

return M
