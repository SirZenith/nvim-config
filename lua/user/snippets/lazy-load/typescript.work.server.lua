local cmd_snip = require "cmd-snippet"

local utils = require "user.utils"
local fs_utils = require "user.utils.fs"
-- local snip_utils = require "user.utils.snippet"

local snip_filetype = "typescript"
local s = require("snippet-loader.utils")
local makers = s.snippet_makers(snip_filetype)
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

cmd_snip.register(snip_filetype, {
    ["agent event"] = {
        content = {
            { "AGENT.roleEvent.on('", 1, "', ", 2, ");" },
        },
    },
    ["agent rpc"] = {
        content = {
            { "AGENT.registerRpcAsync('", 1, "', ", 2, ");" },
        },
    },
    ["init sys"] = {
        args = { { "name", is_optional = true }, },
        content = function(name)
            if not name then
                name = vim.api.nvim_buf_get_name(0)
                name = fs_utils.remove_ext(name)
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
    ["new forward-type"] = {
        args = { { "name", is_optional = true } },
        content = function(name)
            if not name then
                name = vim.api.nvim_buf_get_name(0)
                name = fs_utils.remove_ext(name)
                name = vim.fs.basename(name) or ""
            end

            name = utils.underscore_to_camel_case(name)

            return {
                "// 将定义里面的 IAgent 转成 Agent",
                "type ReplaceAgent<T> = T extends (agent: any, ...args: infer P) => infer R ? (agent: Agent, ...args: P) => R : T;",
                "type ReplacedMgrForward = {",
                { "    [K in keyof I", name, "Forward]: ReplaceAgent<I", name, "Forward[K]>;" },
                "};",
            }
        end,
    }
})
