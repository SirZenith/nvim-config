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
local user = require "user"
local table_utils = require "user.utils.table"
local fs = require "user.utils.fs"
local import = require "user.utils".import

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
    conds_ext = require "user.snippets.utils.cond",
}

-- ----------------------------------------------------------------------------

local pending_snippets_map = {}

---@type { [string]: boolean }
M.loaded_snippets_set = {}

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

---@param filetype string
function M.snippet_makers(filetype)
    -- snippets are stored in tables before finalize
    local record = pending_snippets_map[filetype]
    if not record then
        record = {}
        pending_snippets_map[filetype] = record
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

---@param tbl (string | number | Node)[]
---@param index_set table<number, boolean>
---@return Node[]
local function parse_line_element_table(tbl, index_set)
    local nodes = {}

    for i = 1, #tbl do
        local element = tbl[i]
        if type(element) == "string" then
            table.insert(nodes, M.t(element))
        elseif type(element) == "number" then
            local new_node
            if not index_set[element] then
                new_node = M.i(element)
            else
                new_node = M.f(function(args) return args[1][1] end, { element })
            end

            table.insert(nodes, new_node)
            index_set[element] = true
        elseif type(element) == "table" then
            table.insert(nodes, element)
        end
    end

    return nodes
end

---@param tbl (string | table)[]
function M.parse_table(tbl)
    local nodes = {}
    local index_set = {}

    local len = #tbl
    for i = 1, len do
        local line = tbl[i]
        if type(line) == "string" then
            table.insert(nodes, M.t(line))
        elseif type(line) == "table" then
            table_utils.extend_list(nodes, parse_line_element_table(line, index_set))
        end

        if i < len then
            table.insert(nodes, M.t({ "", "" }))
        end
    end

    return nodes
end

-- ----------------------------------------------------------------------------

local function command_snip_func(snip, cmd_map)
    ---@type string
    local cmd = snip.captures[1]
    local segments = vim.split(cmd, " ")

    local result, err = nil, nil
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
            result, err = map_walker(args)
            break
        elseif type(map_walker) == "string" then
            result = map_walker
            break
        end
    end

    result = result or map_walker

    local nodes = nil
    if type(result) == "string" then
        nodes = M.parse_string(result)
    elseif type(result) ~= "table" then
        if err then
            vim.notify(err);
        end

        nodes = { M.t(":" .. cmd) }
    elseif result.__raw_node then
        nodes = result
    elseif #result ~= 0 then
        nodes = M.parse_table(result)
    else
        vim.notify("snippet command ends at an non-parse table")
    end

    return M.s(1, nodes)
end

function M.command_snip(maker, context, cmd_map)
    context = context or {
        trig = ":(.+);",
        regTrig = true,
        condition = M.conds_ext.line_begin_smart,
    }
    maker(context, M.d(1, function(_, snip)
        return command_snip_func(snip, cmd_map)
    end))
end

-- ----------------------------------------------------------------------------

local function finalize()
    for filetype, record in pairs(pending_snippets_map) do
        ls.add_snippets(filetype, record.snippets)
        ls.add_snippets(filetype, record.autosnippets, { type = "autosnippets" })
        pending_snippets_map[filetype] = nil
    end
end

---@param filename string
function M.load_snip(filename)
    if M.loaded_snippets_set[filename] then return end

    import(filename)
    finalize()

    M.loaded_snippets_set[filename] = true
end

function M.load_autoload()
    local snippet_dir = fs.path_join(user.env.CONFIG_HOME(), "user", "snippets", "auto-load")
    local files = fs.listdir(snippet_dir)

    for _, filename in ipairs(files) do
        M.load_snip(filename)
    end
end

function M.init_lazy_load()
    local lazyload_group = vim.api.nvim_create_augroup("user.snippets.lazy-load", { clear = true })
    local snippet_dir = fs.path_join(user.env.CONFIG_HOME(), "user", "snippets", "lazy-load")
    local files = fs.listdir(snippet_dir)

    for _, filename in ipairs(files) do
        local basename = vim.fs.basename(filename)
        local filetype = vim.split(basename, ".", { plain = true })[1]
        vim.api.nvim_create_autocmd("FileType", {
            group = lazyload_group,
            pattern = {
                filetype,
                filetype .. ".*",
                "*." .. filetype,
                "*." .. filetype .. ".*",
            },
            callback = function() M.load_snip(filename) end,
        })
    end
end

return M
