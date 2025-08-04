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

apsp("panelinit", [[
local Import = MODULE.Import

local TextMeshProUGUI = TextMeshProUGUI
local UI_BTN = UnityEngine.UI.Button
local UI_IMG = UnityEngine.UI.Image

local UI_MENU_BASE = Import("ui/uisystem/ui_menu_base.lua")

local Log = LOGGING.Logger("${1}")

local Super = UI_MENU_BASE.UIMenuBase
---@class ${1} : UIMenuBase
${1} = Super:Inherit()

function ${1}:OnInit()
    self:InitUI()
end

function ${1}:OnClose()
end

function ${1}:OnShow()
end

function ${1}:InitUI()
    ${0}
end

function ${1}:InitEvents()
end
]])

apsp("bs_progressbar", "BS.ProgressBar9Sprite")

apsp("getcontain", [[local container = self:GetGameObject("panel")]])
