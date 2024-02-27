local user = require "user"
local util = require "user.util"
local fs_util = require "user.util.fs"

local loop = vim.loop
local import = util.import

local M = {}

M.WORKSPACE_CONFIG_DIR_NAME = ".nvim"
M.WORKSPACE_CONFIG_INIT_FILE_BASENAME = "init"
M.WORKSPACE_CONFIG_INIT_FILE_EXTENSION = ".lua"
M.WORKSPACE_CONFIG_INIT_FILE_NAME = M.WORKSPACE_CONFIG_INIT_FILE_BASENAME .. M.WORKSPACE_CONFIG_INIT_FILE_EXTENSION

local config_loaded = false

-- is_workspace_confg_loaded checks whether workspace has been loaded.
---@return boolean
function M.is_workspace_confg_loaded()
    return config_loaded
end

function M.init_workspace()
    local config_dir = M.get_workspace_config_dir_path()
    local config_file = M.get_workspace_config_file_path()
    vim.fn.mkdir(config_dir)
    vim.cmd("e " .. config_file)
    vim.cmd "w"
end

-- Return normalized absolute workspace path.
---@return string path
function M.get_workspace_path()
    local cwd = vim.fn.getcwd()
    return vim.fs.normalize(cwd)
end

---@return string path
function M.get_workspace_config_dir_path()
    return fs_util.path_join(
        M.get_workspace_path(),
        M.WORKSPACE_CONFIG_DIR_NAME
    )
end

---@return string path
function M.get_workspace_config_file_path()
    return fs_util.path_join(
        M.get_workspace_path(),
        M.WORKSPACE_CONFIG_DIR_NAME,
        M.WORKSPACE_CONFIG_INIT_FILE_NAME
    )
end

---@return string path
function M.get_workspace_config_require_path()
    return fs_util.path_join(
        M.WORKSPACE_CONFIG_DIR_NAME,
        M.WORKSPACE_CONFIG_INIT_FILE_BASENAME
    )
end

-- After loading workspace config, this value will be replaced by finalize value
-- of workspace config.
M.finalize = function() end

---@param callback fun()
function M.load(callback)
    local file_path = M.get_workspace_config_file_path()
    if vim.fn.filereadable(file_path) == 0 then
        callback()
        return
    end

    if not vim.secure.read(file_path) then
        callback()
        return
    end

    local result = user:with_source(
        user.__source_type.Workspace,
        import,
        M.get_workspace_config_require_path()
    )

    if not result then
        callback()
        return
    end

    config_loaded = true

    local result_type = type(result)
    local finalize
    if result_type == "function" then
        finalize = result
    elseif result_type == "table" then
        finalize = result.finalize
    end

    M.finalize = finalize

    callback()
end

return M
