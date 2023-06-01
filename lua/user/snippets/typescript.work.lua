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
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp('panelinit', [[
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
    protected onInit(): void {
    }

    protected initEvents(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {
    }

    protected onShow(args: UI_COMMON.TYPE_SHOW_PANEL_ARGS): void {
    }

    protected onClose(): void {
    }
}
]])

makers.finalize()
