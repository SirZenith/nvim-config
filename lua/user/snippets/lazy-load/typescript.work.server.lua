local cmd_snip = require "cmd-snippet"

local util = require "user.util"
local fs_util = require "user.util.fs"
local str_util = require "user.util.str"
local snippet_util = require "user.util.snippet"

local snip_filetype = "typescript"
local s = require("snippet-loader.utils")
-- local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
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

---@param index number
---@return any
local function event_callback_name(index)
    return snippet_util.dynamic_conversion(index, function(str)
        return "on" .. str_util.first_char_upper(str)
    end)
end

---@param index number
---@return any
local function rpc_callback_name(index)
    return snippet_util.dynamic_conversion(index, function(str)
        local segments = vim.split(str, "/")
        local name = segments[#segments]
        return "on" .. str_util.first_char_upper(name)
    end)
end

---@param index number
---@return any
local function res_type_name(index)
    return snippet_util.dynamic_conversion(index, function(req_type_name)
        if req_type_name:sub(1, 3):lower() ~= "req" then
            return req_type_name
        end
        return req_type_name:sub(4)
    end)
end

cmd_snip.register(snip_filetype, {
    ["agent event"] = {
        content = {
            { "AGENT.roleEvent.on('", 1, "', ", event_callback_name(1), ");" },
        },
    },
    ["agent rpc"] = {
        content = {
            { "AGENT.registerRpcAsync('", 1, "', ", rpc_callback_name(1), "Async);" },
        },
    },

    ["forward event-interface"] = {
        args = { { "name", is_optional = true } },
        content = function(name)
            if not name then
                name = vim.api.nvim_buf_get_name(0)
                name = fs_util.remove_ext(name)
                name = vim.fs.basename(name) or ""
            end

            name = str_util.underscore_to_camel_case(name)
            name = "I" .. name .. "Forward"

            return {
                "// 将定义里面的 IAgent 转成 Agent",
                "type ReplaceAgent<T> = T extends (agent: any, ...args: infer P) => infer R ? (agent: Agent, ...args: P) => R : T;",
                "type ReplacedMgrForward = {",
                { "    [K in keyof ", name, "]: ReplaceAgent<I", name, "Forward[K]>;" },
                "};",
            }
        end,
    },
    ["forward register"] = {
        args = { "name" },
        content = function(name)
            name = str_util.first_char_upper(name)
            return {
                { "forward", name,         "Event: (agent: Agent, ...args: [any]): void => {" },
                { "    ",    name:upper(), "_MGR.onEvent(agent, ...args);" },
                "},",
            }
        end,
    },
    ["forward tbl"] = {
        content = function()
            local name = vim.api.nvim_buf_get_name(0)
            name = fs_util.remove_ext(name)
            name = vim.fs.basename(name) or ""
            name = str_util.underscore_to_camel_case(name)
            name = "I" .. name .. "Forward"

            return {
                "// 事件注册",
                "const eventTbl: ReplacedMgrForward = {};",
                "",
                { "export const onEvent = (agent: Agent, ev: keyof ", name, ", ...args: unknown[]): void => {" },
                "    const func = eventTbl[ev] as (agent: Agent, ...args: unknown[]) => void;",
                "    func(agent, ...args);",
                "};",
            }
        end,
    },
    ["forward tbl-entry"] = {
        content = {
            { 1, ": ", event_callback_name(1) },
        },
    },

    ["init mgr"] = {
        args = { { "name", is_optional = true }, },
        content = function(name)
            if not name then
                name = vim.api.nvim_buf_get_name(0)
                name = fs_util.remove_ext(name)
                name = vim.fs.basename(name) or ""
            end

            return {
                "import { Agent, AGENT } from '@agent/src/agent/agent';",
                "import { IServerRole } from '@agent/src/agent/agent_interface';",
                "import { serviceCall, serviceSend } from '@share/network/service_network';",
                "import { COMMON_CONST } from 'script_logic/common/common_const';",
                "",
                { "export namespace ", name:upper(), " {}" },
                "",
                "const __init__ = (): void => {};",
                "",
                { "// ",               1 },
                "export const registerSysModule = (): void => {",
                "    __init__();",
                "};",
            }
        end,
    },
    ["init srv"] = {
        args = { { "name", is_optional = true }, },
        content = function(name)
            if not name then
                name = vim.api.nvim_buf_get_name(0)
                name = fs_util.remove_ext(name)
                name = vim.fs.basename(name) or ""
            end

            return {
                "import { SHUTDOWN } from '@share/base/shutdown/shutdown';",
                "import { MONGO_UTIL } from '@share/db/mongo_util';",
                "import { SERVER_EVENT, getServerOpenTime } from '@share/event/server_event';",
                "import { NODE_RPC } from '@share/network/node_rpc';",
                "import { TIMER } from 'script_logic/common/base/timer';",
                "import { COMMON_CONST } from 'script_logic/common/common_const';",
                "",
                { "const SHUTDOWN_TASK_KEY = '", name, "';" },
                "const TICK_INTERVAL = 5_000;",
                "",
                "let tickTimer: TIMER.HANDLER | null = null;",
                "",
                "// ----------------------------------------------------------------------------",
                "// #region 定时任务",
                "",
                "const onTick = async (): Promise<void> => {};",
                "",
                "const cancelTickTimer = (): void => {",
                "    if (tickTimer) {",
                "        TIMER.clearTimer(tickTimer);",
                "        tickTimer = null;",
                "    }",
                "};",
                "",
                "const initTickTimer = (): void => {",
                "    cancelTickTimer();",
                "    tickTimer = TIMER.addRepeatTimer(TICK_INTERVAL, onTick);",
                "};",
                "",
                "// #endregion 定时任务",
                "// ----------------------------------------------------------------------------",
                "// #region 事件响应",
                "",
                "const onServerAcrossDay = async (): Promise<void> => {};",
                "",
                "const onServerStartCompleted = (): void => {};",
                "",
                "const onBeginShutdown = (): Promise<number> => {",
                "    return new Promise((resolve) => {",
                "        cancelTickTimer();",
                "        onTick();",
                "        resolve(COMMON_CONST.ONE);",
                "    });",
                "};",
                "",
                "const registerShutdownTask = (): void => {",
                "    SHUTDOWN.registerTask({",
                "        key: SHUTDOWN_TASK_KEY,",
                "        onBeginShutdown,",
                "    });",
                "};",
                "",
                "// #region 事件响应",
                "// ----------------------------------------------------------------------------",
                "",
                "const __init__ = (): void => {",
                "    SERVER_EVENT.event.on('ServerAcrossDay', onServerAcrossDay);",
                "    SERVER_EVENT.event.on('ServerStartCompleted', onServerStartCompleted);",
                "",
                "    registerShutdownTask();",
                "    initTickTimer();",
                "};",
                "",
                "// 循环节日活动服务",
                "export const registersysmodule = (): void => {",
                "    __init__();",
                "};",
            }
        end,
    },

    ["proto fd"] = {
        args = {
            { "id",   type = "number" },
            { "name" },
            { "desc", is_varg = true },
        },
        content = function(id, name, ...)
            local desc = table.concat({ ... }, " ")
            return {
                "/**",
                { " * ",            desc },
                { " * PropertyId:", id },
                " */",
                { name, ": ", 1, ";" },
            }
        end,
    },
    ["proto init"] = {
        args = {
            { "range-start", type = "number" },
            { "range-end",   type = "number" },
        },
        content = function(st, ed)
            return {
                "import {} from 'tsrpc-proto';",
                "",
                { "// ProtocolRange:", st, "-", ed },
                "",
            }
        end,
    },
    ["proto new"] = {
        args = {
            { "id",   type = "number" },
            { "name" },
            { "desc", is_varg = true },
        },
        content = function(id, name, ...)
            name = str_util.first_char_upper(name)
            local desc = table.concat({ ... }, " ")
            return {
                "/**",
                { " * ", desc, "请求" },
                { " * ProtocolId:", id },
                " */",
                { "export interface Req", name, " {" },
                "}",
                "",
                "/**",
                { " * ", desc, "响应" },
                { " * ProtocolId:", id },
                " */",
                { "export interface Res", name, " {" },
                "    /**",
                "     * 是否成功",
                "     * PropertyId:0",
                "     */",
                "    ok: boolean;",
                "    /**",
                "     * 操作失败时的提示信息",
                "     * PropertyId:1",
                "     */",
                "    msg?: string;",
                "}",
            }
        end,
    },
    ["proto new-msg"] = {
        args = {
            { "id",   type = "number" },
            "name",
            { "desc", is_varg = true },
        },
        content = function(id, name, ...)
            name = str_util.first_char_upper(name)
            local desc = table.concat({ ... }, " ")
            return {
                "/**",
                { " * ",            desc },
                { " * ProtocolId:", id },
                " */",
                { "export interface Msg", name, " {" },
                "}",
            }
        end,
    },
    ["proto new-srv"] = {
        args = {
            { "id",   type = "number" },
            { "name" },
            { "desc", is_varg = true },
        },
        content = function(id, name, ...)
            name = str_util.first_char_upper(name)
            local desc = table.concat({ ... }, " ")
            return {
                "/**",
                { " * ", desc, "请求" },
                { " * ProtocolId:", id },
                " */",
                { "export interface NodeReq", name, " {" },
                "}",
                "",
                "/**",
                { " * ", desc, "响应" },
                { " * ProtocolId:", id },
                " */",
                { "export interface NodeRes", name, " {" },
                "    /**",
                "     * 是否成功",
                "     * PropertyId:0",
                "     */",
                "    ok: boolean;",
                "}",
            }
        end,
    },

    ["rpc plain"] = {
        args = { "name" },
        content = function(name)
            return {
                { "export const ", name, " = (agent: Agent, req: ", 1, "): Res", res_type_name(1), " => {};" }
            }
        end,
    },
    ["rpc async"] = {
        args = { "name" },
        content = function(name)
            return {
                { "const ", name, "Async = (agent: Agent, req: ", 1, "): Promise<Res", res_type_name(1), "> => {};" }
            }
        end,
    },
})
