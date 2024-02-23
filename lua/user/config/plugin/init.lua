local user = require "user"
local spec = require "user.config.plugin.spec"
local loader = require "user.config.plugin.loaders.lazy"
local util = require "user.util"

local M = {}

user.plugin = {
    __newentry = true,
}

function M.init()
    -- setup plugin loading keymap leader
    vim.g.mapleader = " "
    loader.setup(spec)
end

function M.finalize()
    util.finalize_module(loader)
end

return M
