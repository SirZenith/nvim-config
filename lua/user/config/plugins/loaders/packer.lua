local user = require "user"
local utils = require "user.utils"
local import = utils.import
local fs = require "user.utils.fs"

local fn = vim.fn

local function require_packer()
    if vim.fn.executable("git") == 0 then
        error("can't find command git")
    end

    local is_bootstrap = false
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

    if fn.empty(fn.glob(install_path)) == 1 then
        is_bootstrap = true

        fn.system {
            "git",
            "clone",
            "--depth",
            "1",
            "https://github.com/wbthomason/packer.nvim",
            install_path,
        }
    end

    vim.cmd "packadd packer.nvim"

    return is_bootstrap, import "packer"
end

local is_bootstrap, packer = require_packer()

-- ----------------------------------------------------------------------------
-- loading helpers

---@param path string # plugin spec path
local function get_config_name(path)
    return fs.path_join("user", "plugins", path, "config.lua")
end

---@param path string # plugin spec path
local function get_keybinding_name(path)
    return fs.path_join("user", "plugins", path, "keybinding.lua")
end

local function do_load(load_func, spec)
    if not load_func then return end

    local before_load = spec.before_load
    local before_load_type = type(before_load)

    if before_load_type == "string" then
        vim.cmd(before_load)
    elseif before_load_type == "function" then
        before_load()
    end

    local ok = xpcall(
        function() load_func(spec) end,
        function(err)
            io.write("while loading: ")
            vim.print(spec)
            vim.notify(debug.traceback() or err)
        end
    )
    return ok
end

local function load(sepc)
    return do_load(packer and packer.use, sepc)
end

local function load_rock(sepc)
    return do_load(packer and packer.use_rock, sepc)
end

-- ----------------------------------------------------------------------------

local M = {}

M._is_bootstrap = is_bootstrap
M._loaded_config_module = {} ---@type table<string, any>

---@param name string # file path relative to user config home directory
local function try_load_file(name)
    local file = fs.path_join(user.env.USER_RUNTIME_PATH(), name)
    if fn.filereadable(file) ~= 0 then
        local module = import(name)
        M._loaded_config_module[name] = module
    end
end

function M.load_config(spec)
    if M._is_bootstrap then return end

    local path
    local spec_type = type(spec)
    if spec_type == "table" then
        path = not spec.disable and spec[1] or nil
    elseif spec_type == "string" then
        path = spec
    end

    if not path or #path == 0 then return end

    local cfg_name = get_config_name(path)
    try_load_file(cfg_name)

    local keybinding_name = get_keybinding_name(path)
    try_load_file(keybinding_name)
end

function M.do_load(load_func, spec)
    local ok = load_func(spec)
    if ok then
        M.load_config(spec)
    end
    return ok
end

function M.load(spec)
    return M.do_load(load, spec)
end

function M.load_rock(spec)
    return M.do_load(load_rock, spec)
end

function M.load_with_specs(sepcs)
    local loaded = {}

    local lo, lo_rock = M.load, M.load_rock
    for _, spec in ipairs(sepcs) do
        local is_rock = type(spec) == "table" and spec.__is_rock == true
        local ok = is_rock and lo_rock(spec) or lo(spec)
        if ok then
            table.insert(loaded, spec)
        end
    end

    for _, spec in ipairs(loaded) do
        M.load_config(spec)
    end
end

function M.init_event_autocmd()
    local plugin_augroup = vim.api.nvim_create_augroup("user.plugin.load-config", { clear = true })

    ---@type table<string, string | string[]>
    local finalize_events = {
        User = "PackerComplete",
        FileType = "*",
        BufRead = "*",
    }

    for event_name, pattern in pairs(finalize_events) do
        vim.api.nvim_create_autocmd(event_name, {
            group = plugin_augroup,
            pattern = pattern,
            callback = M.finalize,
        })
    end
end

function M.setup(specs)
    packer.startup(function()
        M.load_with_specs(specs)
    end)

    if M._is_bootstrap then
        packer.sync()
    else
        packer.install()
    end

    return M
end

function M.finalize()
    for name, module in pairs(M._loaded_config_module) do
        local module_type = type(module)

        local final
        if module_type == "function" then
            final = module
        elseif module_type == "table" then
            final = module.finalize
        end

        local ok = true
        if type(final) == "function" then
            ok = final()
        end

        -- ok is treated as `true` when has `nil` value
        if ok ~= false then
            M._loaded_config_module[name] = nil
        end
    end
end

return M
