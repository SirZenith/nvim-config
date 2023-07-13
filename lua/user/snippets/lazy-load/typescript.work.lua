local utils = require "user.utils"
local table_utils = require "user.utils.table"

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

local INIT_PANEL = {
    "import { S } from 'script_logic/base/global/singleton';",
    "import { UIBase } from 'script_logic/base/ui_system/ui_base';",
    "import { uiRegister } from 'script_logic/base/ui_system/ui_class_map';",
    "import { UI_COMMON } from 'script_logic/base/ui_system/ui_common';",
    "import { UIButton } from 'script_logic/base/ui_system/uiext/ui_button';",
    "import { UIText } from 'script_logic/base/ui_system/uiext/ui_text';",
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

---@param args string[]
---@return string | nil
local function import_module(args)
    local name = args[1]
    local info = import_map[name]
    if not info then
        return nil
    end

    return ("import { %s } from '%s';"):format(
        table.concat(info.names, ", "),
        info.path
    )
end

---@param args string[]
---@return string
local function import_util(args)
    local name = args[1]
    local symbol = name:upper()
    return ("import { %s } from 'script_logic/common/utils/%s';"):format(symbol, name)
end

---@param args string[]
---@return string | nil
local function import_gm_cmd(args)
    local name = args[1]
    if not name then return nil end

    return ("import * as %s from 'script_logic/common/wizcmd/cmds/%s'"):format(name:upper(), name)
end

-- ----------------------------------------------------------------------------

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

---@param args string[]
---@return string | nil
local function get_gameobject_of_type(args)
    local variable = args[1]
    local object = args[2]
    local class_alias = args[3]
    local class_name = game_object_name_map[class_alias]

    if not class_name then
        return nil
    elseif class_name == "" then
        return ("const %s = %s.getGameObject('${1}');"):format(variable, object)
    end

    return ("const %s = %s.getGameObject('${1}', %s);"):format(variable, object, class_name)
end

-- ----------------------------------------------------------------------------

local NEW_CLOSE_BTN = [[
const btnClose = this.getGameObject('node_bg/panel/btn_close', UIButton);
btnClose.setOnClick(this.close.bind(this));
]]

---@param args string[]
---@return string | nil
local function new_function(args)
    local name = args[1]
    local modifier = args[2]
    if not name then return nil end

    local result = "const " .. name .. " = (${2}): ${1:void} => {${3}};"
    if modifier then
        result = modifier .. " " .. result
    end

    return result
end

---@param args string[]
---@return string | nil
local function new_gm_arg(args)
    local name = args[1]
    if not name then return nil end

    return ("{ name: '%s', typ: '${1}', default: ${2} }"):format(name)
end

local GmCmdType = {
    Client = "client",
    Server = "server",
}

---@param args string[]
---@return Node[] | nil
local function new_gm_cmd(args)
    local type = args[1] or "client"

    local buffer = {
        { "'", 1, "': {" },
        "    args: [],",
    }

    if type == GmCmdType.Server then
        table_utils.extend_list(buffer, {
            "    imports: { },",
            { "    server: (agent: IFakeAgent, cmdArgs: ICmdArgsMap, imports: importedMap): void => {" },
            "        // const { } = imports;",
            "        // const role = agent.role;",
            "        // const argName = cmdArgs.argName;",
            "    },"
        })
    elseif type == GmCmdType.Client then
        table_utils.extend_list(buffer, {
            { "    client: (cmdArgs: ICmdArgsMap, imports: importedMap): void => {" },
            "        // const argName = cmdArgs.argName;",
            "    },"
        })
    else
        return nil
    end

    table.insert(buffer, "},")

    return buffer
end

---@param args string[]
---@return string | nil
local function new_method(args)
    local name = args[1]
    if not name then return nil end
    local modifier = args[2] or "private"
    return modifier .. " " .. name .. "(${2}): ${1:void} {${3}}"
end

---@param args string[]
---@return string[] | nil
local function new_scroll(args)
    local name = args[1]
    if not name then return nil end

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
end

---@param args string[]
---@return string[] | nil
local function new_timer(args)
    local name = args[1]
    if not name then return nil end

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
end

local NEW_TOUCH_CLOSE_LAYER = [[
const layer = this.getGameObject('node_bg/layer', UILayer);
layer.setTouchEvent(this.close.bind(this));
]]

-- ----------------------------------------------------------------------------

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

---@param args string[]
---@return string | nil result
---@return string | nil err
local function data_model_field(args)
    local err, name, index, type = arg_list_check(args, "name", "index", "type")
    if err then return nil, err end

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
end

---@param args string[]
---@return string? result
---@return string? err
local function data_model_new(args)
    local err, name, desc = arg_list_check(args, "name", "desc")
    if err then return nil, err end

    return ("setDataModel('%s', '%s', {});"):format(name, desc)
end

-- ----------------------------------------------------------------------------

local context = {
    trig = ":(.+);",
    regTrig = true,
    condition = s.conds_ext.line_begin_smart,
}
s.command_snip(asp, context, {
    dm = {
        fd = data_model_field,
        new = data_model_new,
    },
    gg = get_gameobject_of_type,
    import = {
        gm_cmd = import_gm_cmd,
        module = import_module,
        util = import_util,
    },
    init = {
        data_model = INIT_DATA_MODEL,
        gm = INIT_GM,
        panel = INIT_PANEL,
        sub_panel = INIT_SUB_PANEL,
        tips = INIT_TIPS,
    },
    new = {
        close_btn = NEW_CLOSE_BTN,
        fn = new_function,
        gm = {
            arg = new_gm_arg,
            cmd = new_gm_cmd,
        },
        method = new_method,
        scroll = new_scroll,
        timer = new_timer,
        touch_close = NEW_TOUCH_CLOSE_LAYER,
    },
})
