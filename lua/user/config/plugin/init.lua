local user = require "user"
local spec = require "user.config.plugin.spec"
local loader = require "user.config.plugin.loaders.lazy"
local utils = require "user.utils"

local M = {}

user.plugin = {
    __new_entry = true,
}

function M.init()
    -- setup plugin loading keymap leader
    vim.g.mapleader = " "
    loader.setup(spec)
end

function M.finalize()
    utils.finalize_module(loader)
end

return M
