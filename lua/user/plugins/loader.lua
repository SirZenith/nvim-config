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

local function get_config_name(path)
    return fs.path_join("user", "plugins", path, "config.lua")
end

local function do_load(load_func, spec)
    if not load_func then return end

    local before_load = spec.__before_load
    local before_load_type = type(before_load)

    if before_load_type == "string" then
        vim.cmd(before_load)
    elseif before_load_type == "function" then
        before_load()
    end

    local ok = xpcall(
        function() load_func(spec) end,
        function()
            io.write("while loading: ")
            vim.print(spec)
            vim.notify(debug.traceback())
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
M._loaded_config_module = {}

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
    local file = fs.path_join(user.env.CONFIG_HOME(), cfg_name)

    if fn.filereadable(file) ~= 0 then
        local module = import(cfg_name)
        table.insert(M._loaded_config_module, module)
    end
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

function M.setup(specs)
    packer.startup(function()
        M.load_with_specs(specs)
    end)
    return M
end

function M.finalize()
    if M._is_bootstrap then
        packer.sync()
    else
        packer.install()
        utils.finalize(M._loaded_config_module)
    end
end

return M
