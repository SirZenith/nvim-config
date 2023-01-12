local fs = require "user.utils.fs"

local M = {}

M.WORKSPACE_CONFIG_DIR_NAME = ".nvim"
M.WORKSPACE_CONFIG_INIT_FILE_BASENAME = "init"
M.WORKSPACE_CONFIG_INIT_FILE_EXTENSION = ".lua"
M.WORKSPACE_CONFIG_INIT_FILE_NAME = M.WORKSPACE_CONFIG_INIT_FILE_BASENAME .. M.WORKSPACE_CONFIG_INIT_FILE_EXTENSION

function M.init_workspace()
    local config_dir = M.get_workspace_config_dir_path()
    local config_file = M.get_workspace_config_file_path()
    vim.fn.mkdir(config_dir)
    vim.cmd("e " .. config_file)
    vim.cmd "w"
end

---@return string path
function M.get_workspace_path()
    return vim.fn.getcwd()
end

---@return string path
function M.get_workspace_config_dir_path()
    return fs.path_join(
        M.get_workspace_path(),
        M.WORKSPACE_CONFIG_DIR_NAME
    )
end

---@return string path
function M.get_workspace_config_file_path()
    return fs.path_join(
        M.get_workspace_path(),
        M.WORKSPACE_CONFIG_DIR_NAME,
        M.WORKSPACE_CONFIG_INIT_FILE_NAME
    )
end

---@return string path
function M.get_workspace_config_require_path()
    return fs.path_join(
        M.WORKSPACE_CONFIG_DIR_NAME,
        M.WORKSPACE_CONFIG_INIT_FILE_BASENAME
    )
end

function M.load()
    local file_path = M.get_workspace_config_file_path()
    if vim.fn.filereadable(file_path) == 0 then return end

    local module
    local ok, result = pcall(require, M.get_workspace_config_require_path())
    if ok then
        local result_type = type(result)
        local finalize
        if result_type == "function" then
            finalize = result
        elseif result_type == "table" then
            finalize = module.finalize
        end

        module = {
            finalize = function()
                if finalize then finalize() end
                vim.notify("workspace configuration loaded.")
            end
        }
    else
        vim.notify(result)
    end

    return module
end

return M
