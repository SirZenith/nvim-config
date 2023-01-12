local snip_filetype = "lua"
local s = require("user.snippets.util")
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
apsp("emret", "---@return ")
apsp("emnod", "---@nodiscard ")
apsp("emovld", "---@overload ")

apsp("emgen", "---@generic ")
apsp("emtp", "---@type ")
apsp("emas", "--[[@as $0]]")
apsp("emca", "---@cast ")
apsp("emop", "---@operator ")

apsp("emcl", "---@class ")
apsp("emfd", "---@field ")
apsp("emal", "---@alias ")
apsp("emen", "---@enum ")

apsp("emmod", "---@module ")
apsp("emdiag", "---@diagnostic ")
apsp("emdep", "---@deprecated")
apsp("emver", "---@version ")
apsp("emsee", "---@see")

apsp("emasy", "---@async")
apsp("emme", "---@meta")

makers.finalize()
