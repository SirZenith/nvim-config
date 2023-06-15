# vim:ft=lua.snippet

local snip_filetype = "typescript"
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
local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp("panel-init;", [[
import { S } from 'script_logic/base/global/singleton';
import { UIBase } from 'script_logic/base/ui_system/ui_base';
import { uiRegister } from 'script_logic/base/ui_system/ui_class_map';
import { UI_COMMON } from 'script_logic/base/ui_system/ui_common';
import { UIButton } from 'script_logic/base/ui_system/uiext/ui_button';
import { UIText } from 'script_logic/base/ui_system/uiext/ui_text';
import { LOGGING } from 'script_logic/common/base/logging';

const Log = LOGGING.logger('${1}');

/**
 * ${2}
 *
 */
@uiRegister({
    panelName: '${1}',
    panelDesc: '${2}',
    prefabPath: '${3}',
    fullScreen: true,
    sortOrderType: UI_COMMON.CANVAS_SORT_ORDER.MENU,
})
// eslint-disable-next-line @typescript-eslint/no-unused-vars
class ${0} extends UIBase {
    protected onInit(): void {}

    protected initEvents(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}

    protected onShow(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}

    protected onClose(): void {}
}
]])

apsp("tips-init;", [[
import { LOGGING } from 'script_logic/common/base/logging';
import { TipsTypeMap } from './tips_info_map';
import { UITipsWidgetBase } from './ui_tips_base';

const Log = LOGGING.logger('${1}');

type UITipsArg = TipsTypeMap['${1}']['args'];
export class ${2} extends UITipsWidgetBase<UITipsArg> {
    public getCustomPreloadAssetList(): string[] {
        return [];
    }

    protected initTips(): void {
    }
}
]])

-- -----------------------------------------------------------------------------

---@class ImportInfo
---@field names string[]
---@field path string

---@type table<string, ImportInfo>
local import_map = {
    singleton = {
        names = { "S" },
        path = "script_logic/base/global/singleton"
    }
}

regasp("([_%w]+)%.import;", s.f(function(_, snip)
    local name = snip.captures[1]
    local info = import_map[name]
    if not info then
        return ""
    end

    return ("import { %s } from '%s';"):format(
        table.concat(info.names, ", "),
        info.path
    )
end))

-- -----------------------------------------------------------------------------

---@type table<string, string>
local game_object_name_map = {
    go = "", -- GameObject
    btn = "UIButton",
    text = "UIText",
    img = "UIImage",
    scroll = "UIScrollView",
    prog = "UIProgressBar",
    input = "UIInputField",
    layer = "UILayer",
}

regasp("([_%w]-)%.([_%w]-)%.gg%.([_%w]-);", s.d(1, function(_, snip)
    local variable = snip.captures[1]
    local object = snip.captures[2]
    local class_alias = snip.captures[3]
    local class_name = game_object_name_map[class_alias]

    if not class_name then
        return s.s(1, s.t(class_alias))
    elseif class_name == "" then
        return s.s(1, {
            s.t("const " .. variable .. " = "),
            s.t(object .. ".getGameObject('"),
            s.i(1),
            s.t("');"),
        })
    end

    return s.s(1, {
        s.t("const " .. variable .. " = "),
        s.t(object .. ".getGameObject('"),
        s.i(1),
        s.t("', " .. class_name .. ");"),
    })
end))

-- -----------------------------------------------------------------------------

regasp("([_%w]-)%.init%.timer;", { s.d(1, function(_, snip)
    local name = snip.captures[1]
    return s.s(1, {
        s.t({
            "private init" .. name .. "Timer(): void {",
            "    this.cancel" .. name .. "Timer();",
            "    this.timer" .. name .. " = TIMER.",
        }),
        s.i(1, "addTimer"),
        s.t({
            ";",
            "}",
            "",
            "private cancel" .. name .. "Timer(): void {",
            "    if (this.timer" .. name .. ") {",
            "        TIMER.clearTimer(this.timer" .. name .. ");",
            "        this.timer" .. name .. " = null;",
            "    }",
            "}"
        })
    })
end) })

regasp("([_%w]-)%.new%.function;", {
    s.t("const "),
    s.f(function(_, snip) return snip.captures[1] end),
    s.t(" = ("),
    s.i(2),
    s.t("): "),
    s.i(1, "void"),
    s.t(" => {"),
    s.i(0),
    s.t("};"),
})

regasp("([_%w]-)%.new%.method;", {
    s.t("private "),
    s.f(function(_, snip) return snip.captures[1] end),
    s.t("("),
    s.i(2),
    s.t("): "),
    s.i(1, "void"),
    s.t(" {"),
    s.i(0),
    s.t("}"),
})
