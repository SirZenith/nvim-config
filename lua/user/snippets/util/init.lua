--[[
This module provides a Maker object containing different kinds of maker factory
function by
    local makers = M.snippet_makers()

and snippet makers are store as fields in makers table
    local sp = makers.sp

current basic makers are: sp, psp, asp, apsp.

By prefixing these names with `cond` and `reg`, you get conditional and regex
makers. For example we have `condsp`.

After all snippets are made with maker, one have to call finalize to add all
snippet into luasnip module.

    local utils = require "utils"
    utils.finalize()
]]
local ls = require "luasnip"
local ls_extra = require "luasnip.extras"
local ast_parser = require("luasnip.util.parser.ast_parser")
local parse = require("luasnip.util.parser.neovim_parser").parse
local Str = require("luasnip.util.str")

local M = {
    t = ls.text_node,
    i = ls.insert_node,
    f = ls.function_node,
    c = ls.choice_node,
    s = ls.snippet_node,
    is = ls.indent_snippet_node,
    d = ls.dynamic_node,
    r = ls.restore_node,
    l = ls_extra.lambda,
    rep = ls_extra.rep,
    p = ls_extra.partial,
    m = ls_extra.match,
    n = ls_extra.nonempty,
    dl = ls_extra.dynamic_lambda,
    fmt = require("luasnip.extras.fmt").fmt,
    fmta = require("luasnip.extras.fmt").fmta,
    types = require("luasnip.util.types"),
    conds = require("luasnip.extras.expand_conditions"),
    conds_ext = require "user.snippets.util.cond",
}

-- ----------------------------------------------------------------------------

M.snippets_map = {}

local function maker_factory(maker, snip_table)
    return function(...)
        local sp = maker(...)
        table.insert(snip_table, sp)
    end
end

local function maker_factory_cond(maker, snip_table)
    return function(cond, trig, nodes)
        local sp = maker(trig, nodes)
        sp.condition = cond
        table.insert(snip_table, sp)
    end
end

local function maker_factory_reg(maker, snip_table)
    return function(trig, nodes)
        local sp = maker(trig, nodes)
        sp.regTrig = true
        table.insert(snip_table, sp)
    end
end

M.snippet_makers = function(filetype)
    -- snippets are stored in tables before finalize
    local record = M.snippets_map[filetype]
    if not record then
        record = {}
        M.snippets_map[filetype] = record
    end

    local snippets = record.snippets
    if not snippets then
        snippets = {}
        record.snippets = snippets
    end

    local autosnippets = record.autosnippets
    if not autosnippets then
        autosnippets = {}
        record.autosnippets = autosnippets
    end

    local snip_tables = {
        [""] = snippets, a = autosnippets,
    }
    local base_makers = {
        sp = ls.snippet, psp = ls.parser.parse_snippet,
    }
    local factories = {
        [""] = maker_factory,
        cond = maker_factory_cond,
        reg = maker_factory_reg,
    }
    local makers = {}

    for maker_name, maker_func in pairs(base_makers) do
        for table_name, tbl in pairs(snip_tables) do
            for factory_name, factory in pairs(factories) do
                local name = factory_name .. table_name .. maker_name
                local maker = factory(maker_func, tbl)
                makers[name] = maker
            end
        end
    end

    return makers
end

-- ----------------------------------------------------------------------------

---@param body string
function M.parse_string(body)
    vim.print('parse')
    if body == "" then
        error("empty body")
    end

    local opts = {}
    if opts.dedent == nil then
        opts.dedent = true
    end
    if opts.trim_empty == nil then
        opts.trim_empty = true
    end

    body = Str.sanitize(body)

    local lines = vim.split(body, "\n")
    Str.process_multiline(lines, opts)
    body = table.concat(lines, "\n")

    local ast = parse(body)

    local nodes = ast_parser.to_luasnip_nodes(ast, {
        var_functions = opts.variables,
    })

    return nodes
end

---@type { [string]: Node[] }
local snip_parsing_cache = {}

---@param body string
function M.cached_parse_string(body)
    local nodes = snip_parsing_cache[body]
    if not nodes then
        nodes = M.parse_string(body)
        snip_parsing_cache[body] = nodes
    end
    return nodes
end

-- ----------------------------------------------------------------------------

local function command_snip_func(snip, cmd_map)
    ---@type string
    local cmd = snip.captures[1]
    local segments = vim.split(cmd, " ")

    local result = nil
    ---@type table | string | function | nil
    local map_walker = cmd_map
    for i = 1, #segments do
        if map_walker == nil then
            break
        end

        local seg = segments[i]
        map_walker = map_walker[seg]

        if type(map_walker) == "function" then
            local args = { unpack(segments, i + 1) }
            result = map_walker(args)
            break
        elseif type(map_walker) == "string" then
            result = map_walker
            break
        end
    end

    local nodes = nil
    if not result then
        nodes = { M.t(":" .. cmd) }
    elseif type(result) == "string" then
        nodes = M.parse_string(result)
    else
        nodes = result
    end

    return M.s(1, nodes)
end

function M.command_snip(maker, context, cmd_map)
    maker(context, M.d(1, function(_, snip)
        return command_snip_func(snip, cmd_map)
    end))
end

-- ----------------------------------------------------------------------------

function M.finalize()
    for filetype, record in pairs(M.snippets_map) do
        ls.add_snippets(filetype, record.snippets)
        ls.add_snippets(filetype, record.autosnippets, { type = "autosnippets" })
    end
end

return M
