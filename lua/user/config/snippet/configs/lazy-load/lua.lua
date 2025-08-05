local cmd_snip = require "cmd-snippet"

local snip_filetype = "lua"
local s = require "user.config.snippet.utils"
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
-- local psp = makers.psp
local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
-- local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp("eman", "---@")

apsp("empar", "---@param ")
apsp("emvarg", "---@vararg ")
apsp("emret", "---@return ")
apsp("emnod", "---@nodiscard ")
apsp("emovld", "---@overload ")
apsp("empac", "---@package ")   -- mark a function as private to file
apsp("empac", "---@private ")   -- mark a function as private method of a class
apsp("empac", "---@protected ") -- mark a function as protected method of a class

apsp("emgen", "---@generic ")
apsp("emtp", "---@type ")
apsp("emas", "--[[@as $0]]")
apsp("emca", "---@cast ")
apsp("emop", "---@operator ")

apsp("emcl", "---@class ")
apsp("emfd", "---@field ")
apsp("emal", "---@alias ")
apsp("emen", "---@enum ")

apsp("emmod", "---@module ") -- mark a variable as if it its assigned via a require statement
apsp("emdiag", "---@diagnostic ")
apsp("emdep", "---@deprecated ")
apsp("emver", "---@version ")
apsp("emsee", "---@see ")
apsp("emsee", "---@source ") -- takes path to another file marking a identifier as provided in another file

apsp("emasy", "---@async")
apsp("emme", "---@meta")

-- ----------------------------------------------------------------------------

cmd_snip.register(snip_filetype, {
    argcheck = {
        args = { { "name", is_varg = true } },
        content = function(...)
            local names = { ... }
            local buffer = {}
            for _, name in ipairs(names) do
                table.insert(buffer, ('"%s"'):format(name))
            end

            return {
                ("local err, %s = arg_list_check(args, %s)"):format(
                    table.concat(names, ", "), table.concat(buffer, ", ")
                ),
                "if err then return nil, err end",
            }
        end,
    }
})
