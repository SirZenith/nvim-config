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
            { "AGENT.registerRpcAsync('", 1, "', ", rpc_callback_name(1), ");" },
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
                "import { AGENT, Agent } from '@agent/src/agent/agent';",
                "import { IServerRole } from '@agent/src/agent/agent_interface';",
                "import { serviceCall, serviceSend } from '@share/network/service_network';",
                "import { COMMON_CONST } from 'script_logic/common/common_const';",
                "",
                { "export namespace ", name:upper(), "{}" },
                "const __init__ = (): void => {};",
                "",
                { "// ",               1 },
                "export const registerSysModule = (): void => {",
                "    __init__();",
                "};",
            }
        end,
    },
    ["new event-forward"] = {
        args = { "name" },
        content = function(name)
            name = str_util.first_char_upper(name)
            return {
                "forward", name, "Event: (agent: Agent, ...args: [any]): void => {",
                "    ", name:upper(), "_MGR.onEvent(agent, ...args);",
                "},",
            }
        end,
    },
    ["new event-item"] = {
        content = {
            { 1, ": ", event_callback_name(1) },
        },
    },
    ["new event-tbl"] = {
        content = {
            "    // 事件注册",
            "    const eventTbl: ReplacedMgrForward = {};",
            "",
            { "    export const onEvent = (agent: Agent, ev: keyof ", 1, ", ...args: any[]): void => {" },
            "        const func = eventTbl[ev];",
            "        const fixArgs = args as any;",
            "        func(agent, ...fixArgs);",
            "    };",
        },
    },
    ["new event-tbl-type"] = {
        args = { { "name", is_optional = true } },
        content = function(name)
            if not name then
                name = vim.api.nvim_buf_get_name(0)
                name = fs_util.remove_ext(name)
                name = vim.fs.basename(name) or ""
            end

            name = util.underscore_to_camel_case(name)

            return {
                "// 将定义里面的 IAgent 转成 Agent",
                "type ReplaceAgent<T> = T extends (agent: any, ...args: infer P) => infer R ? (agent: Agent, ...args: P) => R : T;",
                "type ReplacedMgrForward = {",
                { "    [K in keyof I", name, "Forward]: ReplaceAgent<I", name, "Forward[K]>;" },
                "};",
            }
        end,
    },
    ["new req-handler"] = {
        args = { "name" },
        content = function(name)
            return {
                { "export const ", name, " = (agent: Agent, req: ", 1, "): Promise<Res", res_type_name(1), "> => {};" }
            }
        end,
    },
})
