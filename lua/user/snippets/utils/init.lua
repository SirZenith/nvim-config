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

function M.init_conditional_load()
    local conditional_group = vim.api.nvim_create_augroup("user.snippets.conditional-load", { clear = true })
    local snippet_dir = fs.path_join(user.env.CONFIG_HOME(), "user", "snippets", "conditional-load")
    local files = fs.listdir(snippet_dir)

    for _, filename in ipairs(files) do
        local module = import(filename)
        local ok = xpcall(
            function()
                vim.validate {
                    event = { module.event, { "s", "t" } },
                    pattern = { module.pattern, { "s", "t" } },
                    cond_func = { module.cond_func, "f", true },
                    setup = { module.setup, "f" },
                }
            end,
            function(msg)
                msg = ("while loading '%s':\n    %s"):format(filename, msg)
                vim.notify(msg)
            end
        )

        if ok and module then
            vim.api.nvim_create_autocmd(module.event, {
                group = conditional_group,
                pattern = module.pattern,
                callback = function(info)
                    if module.cond_func and not module.cond_func(info) then
                        return
                    end
                    module.setup()
                    finalize()
                end,
            })
        end
    end
end

return M
