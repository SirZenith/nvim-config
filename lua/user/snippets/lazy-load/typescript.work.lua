local utils = require "user.utils"
local table_utils = require "user.utils.table"
local cmd_snip = require "snippet-loader.cmd-snippet"

local snip_filetype = "typescript"
local s = require("snippet-loader.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
local asp = makers.asp
-- local psp = makers.psp
-- local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
-- local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

---@class Node

---@param index number
local function to_camel(index)
    return s.f(function(args)
        return utils.underscore_to_camel_case(args[1][1])
    end, { index })
end

---@param str string
---@return string
local function first_char_upper(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

-- ----------------------------------------------------------------------------

---@class ImportInfo
---@field names string[]
---@field path string

---@type table<string, ImportInfo>
local import_map = {
    client_utility = {
        names = { "CLIENT_UTILITY" },
        path = "script_logic/module/util/client_utility",
    },
    common_const = {
        names = { "COMMON_CONST" },
        path = "script_logic/common/common_const",
    },
    logging = {
        names = { "LOGGING" },
        path = "script_logic/common/base/logging",
    },
    role_event = {
        names = { "ROLE_EVENT" },
        path = "script_logic/event/role_event",
    },
    singleton = {
        names = { "S" },
        path = "script_logic/base/global/singleton",
    },
    ui_utility = {
        names = { "UI_UTILITY" },
        path = "script_logic/ui/ui_common/ui_utility",
    },
}

---@type table<string, { name: string, prefix?: string }>
local game_object_name_map = {
    go = {
        name = "", -- GameObject
    },
    btn = {
        name = "UIButton",
        prefix = "btn",
    },
    text = {
        name = "UIText",
        prefix = "text",
    },
    img = {
        name = "UIImage",
        prefix = "img",
    },
    scroll = {
        name = "UIScrollView",
        prefix = "scroll",
    },
    prog = {
        name = "UIProgressBar",
        prefix = "bar",
    },
    input = {
        name = "UIInputField",
        prefix = "input",
    },
    layer = {
        name = "UILayer",
        prefix = "layer",
    },
}

local GmCmdType = {
    Client = "client",
    Server = "server",
}

local DMFieldTypeInfo = {
    string = nil,
    bool = nil,
    int = { "minLimit", "accum" },
    float = { "minLimit", "accum" },
    table = nil,
    dict = { "idkey", "valueType", "customClass" },
    list = { "valueType", "customClass" },
    map = { "idtype", "valueType", "customClass" },
    specNum = { "category" },
    specDict = { "idkey", "valueType", "category" },
}

-- ----------------------------------------------------------------------------

local INIT_DATA_MODEL = {
    "import { setDataModel } from '../base/struct_helper';",
    "",
}

local INIT_GM = {
    "/* eslint-disable @typescript-eslint/no-magic-numbers */",
    "import { IFakeAgent, ICmdArgsMap, ICmds, importedMap } from 'script_logic/common/wizcmd/wizcmd_interface';",
    "",
    "export const CMDS: ICmds = {",
    { "    rootKey: '", 1, "'," },
    "    childrens: {},",
    "};",
}

local INIT_LABEL_VIEW = {
    "import { uiRegister } from 'script_logic/base/ui_system/ui_class_map';",
    "import { UI_COMMON } from 'script_logic/base/ui_system/ui_common';",
    "import { LOGGING } from 'script_logic/common/base/logging';",
    "import { UILabelView } from 'script_logic/base/ui_system/label_view/ui_label_view';",
    "import { ILabelInfo } from 'script_logic/base/ui_system/label_view/label_view_interface';",
    "",
    { "const Log = LOGGING.logger('", 1, "');" },
    "",
    "const enum LabelType {}",
    "",
    "const LABEL_INFO_LIST: ILabelInfo[] = [];",
    "",
    "/**",
    { " * ",                          2 },
    " */",
    "@uiRegister({",
    { "    panelName: '",                                    1, "'," },
    { "    panelDesc: '",                                    2, "'," },
    { "    prefabPath: '",                                   3, "'," },
    { "    fullScreen: ",                                    4, "," },
    { "    sortOrderType: UI_COMMON.CANVAS_SORT_ORDER.MENU," },
    "})",
    "// eslint-disable-next-line @typescript-eslint/no-unused-vars",
    { "export class ", to_camel(1), " extends UILabelView {" },
    "    protected onInit(): void {}",
    "",
    "    protected prepareLabelInfo(): void {",
    "        this._labelInfoDict = new Map<number, ILabelInfo>();",
    "",
    "        for (const labelInfo of LABEL_INFO_LIST) {",
    "            this._labelInfoDict.set(labelInfo.labelType!, labelInfo);",
    "        }",
    "",
    "        this.defaultLabelType = null;",
    "    }",
    "",
    "    protected initEvents(): void {}",
    "",
    "    protected onClose(): void {}",
    "}",
}

local INIT_PANEL = {
    "import { S } from 'script_logic/base/global/singleton';",
    "import { UIBase } from 'script_logic/base/ui_system/ui_base';",
    "import { uiRegister } from 'script_logic/base/ui_system/ui_class_map';",
    "import { UI_COMMON } from 'script_logic/base/ui_system/ui_common';",
    "import { LOGGING } from 'script_logic/common/base/logging';",
    "",
    { "const Log = LOGGING.logger('", 1, "');" },
    "",
    "/**",
    { " * ",                          2 },
    " */",
    "@uiRegister({",
    { "    panelName: '",                                    1, "'," },
    { "    panelDesc: '",                                    2, "'," },
    { "    prefabPath: '",                                   3, "'," },
    { "    fullScreen: ",                                    4, "," },
    { "    sortOrderType: UI_COMMON.CANVAS_SORT_ORDER.MENU," },
    "})",
    "// eslint-disable-next-line @typescript-eslint/no-unused-vars",
    { "export class ", to_camel(1), " extends UIBase {" },
    "    protected onInit(): void {}",
    "",
    "    protected initEvents(): void {}",
    "",
    "    protected onShow(): void {}",
    "",
    "    protected onClose(): void {}",
    "}",
}

local INIT_TIPS = {
    "import { LOGGING } from 'script_logic/common/base/logging';",
    "import { TipsTypeMap } from 'script_logic/ui/ui_tips/tips_info_map';",
    "import { UITipsWidgetBase } from 'script_logic/ui/ui_tips/ui_tips_base';",
    "",
    { "const Log = LOGGING.logger('",   1,           "');" },
    "",
    { "type UITipsArg = TipsTypeMap['", 1,           "']['args'];" },
    { "export class ",                  to_camel(1), " extends UITipsWidgetBase<UITipsArg> {" },
    "    public getCustomPreloadAssetList(): string[] {",
    "        return [];",
    "    }",
    "",
    "    protected initTips(): void {}",
    "}",
}

local INIT_SUB_PANEL = {
    "import { LOGGING } from 'script_logic/common/base/logging';",
    "import { UISubView } from 'script_logic/base/ui_system/label_view/ui_sub_view';",
    "",
    { "const Log = LOGGING.logger('", 1,           "');" },
    "",
    { "export class ",                to_camel(1), " extends UISubView {" },
    "    protected onInit(): void {}",
    "",
    "    protected initEvents(): void {}",
    "",
    "    protected onShow(): void {}",
    "",
    "    protected onClose(): void {}",
    "}",
}

local NEW_ADS = {
    { "// #region ", 2 },
    "",
    "/**",
    " * @param role - 玩家数据",
    { " * @returns 今天已经观看", 2, "广告的次数" },
    " */",
    { "export const get",                                          1, "CurCount = (role: Role): number => {" },
    "// TODO",
    { "    const cnt = SPAN_COUNTER.getDayCount(role as Role, ad", 1, "Flag);" },
    "    return cnt;",
    "};",
    "",
    "/**",
    { " * @returns ", 2, "广告今日可看最大次数" },
    " */",
    { "export const get", 1, "MaxCnt = (): number => {" },
    "// TODO",
    { "    const maxCnt = GLOBAL_CONFIG.getConfigValue('') as number;" },
    "    return maxCnt;",
    "};",
    "",
    "/**",
    " * @param role - 玩家数据",
    { " * @returns ", 2, "广告 CD 结束的时间" },
    " */",
    { "export const getNext",       1, "Ts = (role: Role): number => {" },
    "    const adsData = role.adsData;",
    "    if (!adsData) {",
    "        return COMMON_CONST.ZERO;",
    "    }",
    "",
    "    // TODO",
    { "    const ts = adsData.get", 1, "Ts();" },
    "    const cd = GLOBAL_CONFIG.getConfigValue('');",
    "    return ts + cd;",
    "};",
    "",
    "/**",
    " * @param role - 玩家数据",
    { " * @returns 玩家当前是否可以观看", 2, "广告" },
    " */",
    { "export const is", 1, "CanPlayAd = (role: Role): IOkLocaleErrRet => {" },
    "    const adsData = role.adsData;",
    "    if (!adsData) {",
    "        // 第一次看",
    "        return { ok: true };",
    "    }",
    "",
    { "    const cnt = get",    1, "CurCount(role);" },
    { "    const maxCnt = get", 1, "MaxCnt();" },
    "    if (cnt >= maxCnt) {",
    "        return { ok: false };",
    "    }",
    "",
    { "    const nextTs = getNext", 1, "Ts(role);" },
    "    const now = TIMES.now();",
    "    if (now < nextTs) {",
    "        return { ok: false };",
    "    }",
    "",
    "    return { ok: true };",
    "};",
    "",
    { "// #endregion ",             2 },
}

local NEW_CLOSE_BTN = [[
const btnClose = this.getGameObject('node_bg/panel/btn_close', UIButton);
btnClose.setOnClick(this.close.bind(this));
]]

local NEW_LABEL_INFO = {
    "{",
    { "    labelType: ",      1, "," },
    { "    prefab: '",        2, "'," },
    { "    clsClass: ",       3, "," },
    { "    text: '",          4, "'," },
    { "    iconPath: '",      5, "'," },
    { "    iconPathUnSel: '", 6, "'," },
    { "    showOrder: ",      7, "," },
    "},",
}

local NEW_TOUCH_CLOSE_LAYER = [[
const layer = this.getGameObject('node_bg/layer', UILayer);
layer.setTouchEvent(this.close.bind(this));
]]

-- ----------------------------------------------------------------------------

cmd_snip.register {
    ["dm fd"] = {
        args = { "name", "index", "type" },
        content = function(name, index, type)
            index = tonumber(index) or 0
            local buffer = {
                name, ": { index: ", tostring(index), ", typ: '", type, "'",
            }

            local extra_args = DMFieldTypeInfo[type] or {}
            local jump_index = 1
            for _, field in ipairs(extra_args) do
                table.insert(buffer, ", ")
                table.insert(buffer, field)
                table.insert(buffer, (": ${%d}"):format(jump_index))
                jump_index = jump_index + 1
            end

            table.insert(buffer, (", desc: '${%d}' },"):format(jump_index))

            return table.concat(buffer)
        end,
    },
    ["dm new"] = {
        args = { "name", "desc" },
        content = function(name, desc)
            return ("setDataModel('%s', '%s', {});"):format(name, desc)
        end,
    },
    fn = {
        args = { "modifier-or-name", { "name", is_optional = true } },
        content = function(modifier_or_name, name)
            local modifier = name and modifier_or_name or ""
            name = name or modifier_or_name

            local result = "const " .. name .. " = (${2}): ${1:void} => {};"
            if modifier then
                result = modifier .. " " .. result
            end

            return result
        end,
    },
    ["get keys"] = {
        content = {
            { "const keys = Object.keys(", 1, ");" },
        }
    },
    ["get values"] = {
        content = {
            { "const values = Object.values(", 1, ");" },
        }
    },
    gg = {
        -- get game object of type
        args = { "class-alias", "variable", "object" },
        content = function(class_alias, variable, object)
            local info = game_object_name_map[class_alias]
            if not info then return nil end

            local class_name = info.name;
            if not class_name then return nil end

            local prefix = info.prefix
            if prefix then
                variable = prefix .. first_char_upper(variable)
            end

            if class_name == "" then
                return ("const %s = %s.getGameObject('${1}');"):format(variable, object)
            end

            return ("const %s = %s.getGameObject('${1}', %s);"):format(variable, object, class_name)
        end,
    },
    ["import event"] = {
        args = { "name" },
        content = function(name)
            local module_name = name .. "_event";
            return ("import { %s } from 'script_logic/event/%s';"):format(module_name:upper(), module_name)
        end,
    },
    ["import gm"] = {
        args = { "name" },
        content = function(name)
            return ("import * as %s from 'script_logic/common/wizcmd/cmds/%s'"):format(name:upper(), name)
        end,
    },
    ["import module"] = {
        args = { "name" },
        content = function(name)
            local info = import_map[name]
            if not info then
                return nil
            end

            return ("import { %s } from '%s';"):format(
                table.concat(info.names, ", "),
                info.path
            )
        end,
    },
    ["import ptl"] = {
        args = { "name" },
        content = function(name)
            local module_name = utils.underscore_to_camel_case(name)
            return {
                { "import { } from 'script_logic/common/proto/define/c2s/", module_name, "';" }
            }
        end,
    },
    ["import rolemodule"] = {
        args = { "name" },
        content = function(name)
            return {
                { "import { ", name:upper(), " } from 'script_logic/module/role/", name, "';" }
            }
        end,
    },
    ["import util"] = {
        args = { "name" },
        content = function(name)
            local symbol = name:upper()
            return ("import { %s } from 'script_logic/common/utils/%s';"):format(symbol, name)
        end,
    },
    ["init data_model"] = {
        content = INIT_DATA_MODEL,
    },
    ["init event"] = {
        args = { "name" },
        content = function(name)
            local event_name = name .. "_event"
            return {
                "import { CustomEventEmitter, EVENT_EMITTER, IEvent } from 'script_logic/common/base/event_emitter';",
                "interface ICustomEvent extends IEvent {",
                { "    name: '",       event_name,         "';" },
                "    events: {};",
                "}",
                "",
                "type TYPE_CUSTOM = CustomEventEmitter<ICustomEvent>;",
                "",
                { "export namespace ", event_name:upper(), " {" },
                "    export type eventEmitterType = TYPE_CUSTOM;",
                "",
                "    export type eventType = ICustomEvent;",
                "",
                "    export const event: CustomEventEmitter<ICustomEvent> = EVENT_EMITTER.bindSingleon<ICustomEvent>();",
                "}",
            }
        end,
    },
    ["init gm"] = {
        content = INIT_GM,
    },
    ["init label_view"] = {
        content = INIT_LABEL_VIEW,
    },
    ["init panel"] = {
        content = INIT_PANEL,
    },
    ["init rolemodule"] = {
        args = { "name" },
        content = function(name)
            return {
                { "export namespace ", name:upper(), " {" },
                "    // --------- 通用玩家单例方法 begin-------",
                "    export const onRoleDataReady = (): void => {};",
                "",
                "    export const onRoleEnterWorld = (): void => {};",
                "",
                "    export const onRoleQuitWorld = (): void => {};",
                "",
                "    export const onLoginStartReconnect = (): void => {};",
                "",
                "    export const onLoginStartConnect = (): void => {};",
                "    // --------- 通用玩家单例方法 end-------",
                "}",
            }
        end,
    },
    ["init sub_panel"] = {
        content = INIT_SUB_PANEL,
    },
    ["init tips"] = {
        content = INIT_TIPS,
    },
    ["gm arg"] = {
        args = { "name" },
        content = function(name)
            return ("{ name: '%s', typ: '${1}', default: ${2} }"):format(name)
        end,
    },
    ["gm cmd"] = {
        args = { { "type", is_optional = true } },
        content = function(type)
            type = type or "client"
            local buffer = {
                { "'", 1, "': {" },
                "    args: [],",
            }

            if type == GmCmdType.Server then
                table_utils.extend_list(buffer, {
                    "    imports: { },",
                    "    server: (agent: IFakeAgent, cmdArgs: ICmdArgsMap, imports: importedMap): void => {",
                    "        // const { } = imports;",
                    "        // const role = agent.role;",
                    "        // const { } = cmdArgs;",
                    "    },"
                })
            elseif type == GmCmdType.Client then
                table_utils.extend_list(buffer, {
                    "    client: (cmdArgs: ICmdArgsMap, imports: importedMap): void => {",
                    "        // const { } = imports;",
                    "        // const { } = cmdArgs;",
                    "    },"
                })
            else
                return nil
            end

            table.insert(buffer, "},")

            return buffer
        end,
    },
    method = {
        args = { "modifier-or-name", { "name", is_optional = true } },
        content = function(modifier_or_name, name)
            local modifier = name and modifier_or_name or "private"
            name = name or modifier_or_name
            return modifier .. " " .. name .. "(${2}): ${1:void} {}"
        end,
    },
    ["new ads"] = {
        args = { "ads_name", "ads_desc_name" },
        content = function(ads_name, ads_desc_name)
            return s.snippet_tbl_substitute(NEW_ADS, {
                [1] = first_char_upper(ads_name),
                [2] = ads_desc_name,
            })
        end,
    },
    ["new close_btn"] = {
        content = NEW_CLOSE_BTN,
    },
    ["new label_info"] = {
        content = NEW_LABEL_INFO,
    },
    ["new logger"] = {
        args = { "name" },
        content = function(name)
            return "const Log = LOGGING.logger('" .. name .. "');"
        end,
    },
    ["new reddot"] = {
        args = { "name" },
        content = function(name)
            local key_name = name .. "Key"
            local node_name = name .. "Node"
            return {
                { "const ",  key_name,               " = ",                         1,        " + '", name, "';" },
                { "const ",  node_name,              " = reddotMgr.addNodeByPath(", key_name, ", '",  2,    "');" },
                { node_name, ".setCheckFunc(() => {" },
                "    return false;",
                "});",
            }
        end,
    },
    ["new request"] = {
        args = { "name", { "flag_name", is_optional = true } },
        content = function(name, flag_name)
            flag_name = flag_name or name
            return {
                { "private do",             first_char_upper(name),      "(",  1, "): void {" },
                { "    if (this.requested", first_char_upper(flag_name), ") {" },
                "        return;",
                "    }",
                "",
                "}",
            }
        end,
    },
    ["new scroll"] = {
        args = { "name" },
        content = function(name)
            name = first_char_upper(name)
            return {
                "private update" .. name .. "Scroll(): void {",
                { "    const scroll = this.getGameObject('", 1, "', UIScrollView);" },
                "    scroll.setUpdateItemCallback(this.update" .. name .. "Item.bind(this));",
                "",
                "    const totalCnt = COMMON_CONST.ZERO;",
                "    if (totalCnt === scroll.getTotalCount()) {",
                "        scroll.refreshCells();",
                "    } else {",
                "        scroll.setTotalCount(totalCnt);",
                "    }",
                "}",
                "",
                "private update" .. name .. "Item(item: GameObject, index: number): void {}",
            }
        end,
    },
    ["new textid"] = {
        args = { "name" },
        content = function(name)
            local varName = 'textId' .. first_char_upper(name)
            return "const " .. varName .. ": LOCALE.textIdType = '';"
        end,
    },
    ["new timer"] = {
        args = { "name" },
        content = function(name)
            name = first_char_upper(name)
            return {
                "private init" .. name .. "Timer(): void {",
                "    this.cancel" .. name .. "Timer();",
                { "    this.timer" .. name .. " = TIMER.", 1, "();" },
                "}",
                "",
                "private cancel" .. name .. "Timer(): void {",
                "    if (this.timer" .. name .. ") {",
                "        TIMER.clearTimer(this.timer" .. name .. ");",
                "        this.timer" .. name .. " = null;",
                "    }",
                "}",
            }
        end,
    },
    ["new touch_close"] = {
        content = NEW_TOUCH_CLOSE_LAYER,
    },
    ["spine new"] = {
        content = {
            { "const panelModel = this.getGameObject('", 1, "');" },
            "this.modelRenderer = S.uiModelManager.createRenderModel(panelModel);",
        },
    },
    ["spine clean"] = {
        content = {
            "if (this.modelRenderer) {",
            "    S.uiModelManager.removeRenderTextureObj(this.modelRenderer);",
            "    this.modelRenderer = null;",
            "}",
        },
    },
    ["spine set"] = {
        content = {
            "if (this.modelRenderer === null) {",
            "    return;",
            "}",
            "",
            "this.modelRenderer.removeModel();",
            { "const modelId = ", 1 },
            "S.uiModelManager.showRoleModel(this.modelRenderer, {",
            "    modelId,",
            "});",
        },
    },
}
