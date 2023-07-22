local utils = require "user.utils"
local table_utils = require "user.utils.table"
local cmd_snip = require "user.snippets.cmd-snippet"

local arg_list_check = utils.arg_list_check

local snip_filetype = "typescript"
local s = require("user.snippets.utils")
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
        name ="", -- GameObject
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
    specNum = { "catetory" },
    specDict = { "idkey", "valueType", "catetory" },
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
    " *",
    " */",
    "@uiRegister({",
    { "    panelName: '",                                    1, "'," },
    { "    panelDesc: '",                                    2, "'," },
    { "    prefabPath: '",                                   3, "'," },
    { "    fullScreen: true," },
    { "    sortOrderType: UI_COMMON.CANVAS_SORT_ORDER.MENU," },
    "})",
    "// eslint-disable-next-line @typescript-eslint/no-unused-vars",
    { "class ", to_camel(1), " extends UILabelView {" },
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
    "    protected initEvents(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}",
    "",
    "    protected onShow(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}",
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
    " *",
    " */",
    "@uiRegister({",
    { "    panelName: '",                                    1, "'," },
    { "    panelDesc: '",                                    2, "'," },
    { "    prefabPath: '",                                   3, "'," },
    { "    fullScreen: true," },
    { "    sortOrderType: UI_COMMON.CANVAS_SORT_ORDER.MENU," },
    "})",
    "// eslint-disable-next-line @typescript-eslint/no-unused-vars",
    { "class ", to_camel(1), " extends UIBase {" },
    "    protected onInit(): void {}",
    "",
    "    protected initEvents(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}",
    "",
    "    protected onShow(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}",
    "",
    "    protected onClose(): void {}",
    "}",
}

local INIT_TIPS = {
    "import { LOGGING } from 'script_logic/common/base/logging';",
    "import { TipsTypeMap } from './tips_info_map';",
    "import { UITipsWidgetBase } from './ui_tips_base';",
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
    "import { UI_COMMON } from 'script_logic/base/ui_system/ui_common';",
    "import { UISubView } from 'script_logic/base/ui_system/label_view/ui_sub_view';",
    "",
    { "const Log = LOGGING.logger('", 1,           "');" },
    "",
    { "export class ",                to_camel(1), " extends UISubView {" },
    "    protected onInit(): void {}",
    "",
    "    protected initEvents(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}",
    "",
    "    protected onShow(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {}",
    "",
    "    protected onClose(): void {}",
    "}",
}

local NEW_CLOSE_BTN = [[
const btnClose = this.getGameObject('node_bg/panel/btn_close', UIButton);
btnClose.setOnClick(this.close.bind(this));
]]

local NEW_LABEL_INFO = {
    "{",
    { "    labelType: ", 1, ","},
    { "    prefab: '", 2 ,"'," },
    { "    clsClass: ", 3, "," },
    { "    text: '", 4, "'," },
    { "    iconPath: '", 5, "'," },
    { "    iconPathUnSel: '", 6, "'," },
    { "    showOrder: '", 7, "'," },
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
            local extra_args = DMFieldTypeInfo[type] or {}
            local jump_index = 1
            local buffer = {}
            for _, field in ipairs(extra_args) do
                table.insert(buffer, " ")
                table.insert(buffer, field)
                table.insert(buffer, (": ${%d},"):format(jump_index))
                jump_index = jump_index + 1
            end

            return ("%s: { index: %d, typ: '%s',%s desc: '${%d}' },"):format(
                name, index, type, table.concat(buffer), jump_index
            )
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

            local result = "const " .. name .. " = (${2}): ${1:void} => {${3}};"
            if modifier then
                result = modifier .. " " .. result
            end

            return result
        end,
    },
    ["get keys"] = {
        content = {
            {"const keys = Object.keys(", 1, ");"},
        }
    },
    ["get values"] = {
        content = {
            {"const values = Object.values(", 1, ");"},
        }
    },
    gg = {
        -- get game object of type
        args = { "variable", "object", "class-alias" },
        content = function(variable, object, class_alias)
            local info = game_object_name_map[class_alias]
            if not info then return nil end

            local class_name = info.name;
            if not class_name then return nil end

            local prefix = info.prefix
            if prefix then
                variable = prefix .. variable:sub(1, 1):upper() .. variable:sub(2, #variable)
            end

            if class_name == "" then
                return ("const %s = %s.getGameObject('${1}');"):format(variable, object)
            end

            return ("const %s = %s.getGameObject('${1}', %s);"):format(variable, object, class_name)
        end,
    },
    ["import gm_cmd"] = {
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
    ["init gm"] = {
        content = INIT_GM,
    },
    ["init label_view"] = {
        content = INIT_LABEL_VIEW,
    },
    ["init panel"] = {
        content = INIT_PANEL,
    },
    ["init sub_panel"] = {
        content = INIT_SUB_PANEL,
    },
    ["init tips"] = {
        content = INIT_TIPS,
    },
    method = {
        args = { "modifier-or-name", { "name", is_optional = true } },
        content = function(modifier_or_name, name)
            local modifier = name and modifier_or_name or "private"
            name = name or modifier_or_name
            return modifier .. " " .. name .. "(${2}): ${1:void} {${3}}"
        end,
    },
    ["new gm arg"] = {
        args = { "name" },
        content = function(name)
            return ("{ name: '%s', typ: '${1}', default: ${2} }"):format(name)
        end,
    },
    ["new gm cmd"] = {
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
                    "        // const argName = cmdArgs.argName;",
                    "    },"
                })
            elseif type == GmCmdType.Client then
                table_utils.extend_list(buffer, {
                    "    client: (cmdArgs: ICmdArgsMap, imports: importedMap): void => {",
                    "        // const { } = imports;",
                    "        // const argName = cmdArgs.argName;",
                    "    },"
                })
            else
                return nil
            end

            table.insert(buffer, "},")

            return buffer
        end,
    },
    ["new close_btn"] = {
        content = NEW_CLOSE_BTN,
    },
    ["new label_info"] = {
        content = NEW_LABEL_INFO,
    },
    ["new request"] = {
        args = { "name", { "flag_name", is_optional = true } },
        content = function(name, flag_name)
            flag_name = flag_name or name
            return {
                { "private ", name, "(", 1 ,"): void {" },
                { "    if (this.requested", flag_name, ") {" },
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
            return {
                "private update" .. name .. "Scroll(): void {",
                { "    const scroll = this.getGameObject('", 1, "', UIScrollView);" },
                "    scroll.setUpdateItemCallback(this.update" .. name .. "Item.bind(this));",
                "",
                "    const totalCnt = COMMON_CONST.ZERO;",
                "    scroll.setTotalCount(totalCnt);",
                "}",
                "",
                "private update" .. name .. "Item(item: GameObject, index: number): void {}",
            }
        end,
    },
    ["new timer"] = {
        args = { "name" },
        content = function(name)
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
