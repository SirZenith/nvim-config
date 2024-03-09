local user = require "user"

---@param e1 cmp.Entry
---@param e2 cmp.Entry
---@return boolean?
local function sort_indexed_args(e1, e2)
    local label1 = e1:get_completion_item().label
    local label2 = e2:get_completion_item().label
    if not (label1 and label2) then
        return
    end

    if label1:sub(1, 1) ~= "#" or label2:sub(1, 1) ~= "#" then
        return
    end

    local index1 = label1:match("^#(%d+):")
    local index2 = label1:match("^#(%d+):")
    if not (index1 and index2) then
        return
    end

    local num1 = tonumber(index1)
    local num2 = tonumber(index2)
    if not (num1 and num2) then
        return
    end

    return num1 < num2
end

return function()
    local cmp = require "cmp"
    local compare = require "cmp.config.compare"
    local mapping = require "user.plugins.nvim-cmp.mapping"

    local cmp_cfg = {
        window = {
            completion = {
                border = "shadow",
                winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
                col_offset = -1,
                side_padding = 0,
            },
            documentation = {
                border = "rounded",
            }
        },
        experimental = {
            ghost_text = true,
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
        },
        snippet = {
            expand = function(args)
                local luasnip = require "luasnip"
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = mapping,
        sources = cmp.config.sources(
            {
                -- completion source registered in user configs
                { name = "cmd-snip-cmp" },
            },
            {
                { name = "tree-sitter-grammar" },
                { name = "prefab-completion" },
            },
            {
                { name = "nvim_lsp" },
                { name = "path" },
                { name = "luasnip" },
            },
            {
                { name = "buffer" },
            }
        ),
        sorting = {
            comparators = {
                sort_indexed_args,
                compare.offset,
                compare.exact,
                compare.score,
                compare.recently_used,
                compare.locality,
                compare.kind,
                compare.sort_text,
                compare.length,
                compare.order,
            },
        },
    }

    local fmt_func

    cmp_cfg.formatting.format = function(entry, vim_item)
        if not fmt_func then
            local lspkind = require "lspkind"
            local lspkind_cfg = user.plugin.lspkind()
            lspkind_cfg.maxwidth = 50
            lspkind_cfg.symbol_map = user.lsp.kind_label()

            fmt_func = lspkind.cmp_format(lspkind_cfg)
        end

        local kind = fmt_func(entry, vim_item)
        local strings = vim.split(kind.kind, "%s+", { trimempty = true })

        kind.kind = (" %s "):format(strings[1] or "-")
        kind.menu = ("(%s)"):format(strings[2] or "[Unknown]")

        return kind
    end

    -- General setup
    cmp.setup(cmp_cfg)

    -- Command mode completion (doesn't work if `native_menu` is on)
    cmp.setup.cmdline("/", {
        sources = {
            { name = "buffer" },
        }
    })

    cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        })
    })

    -- File type scpecific completion

    cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
            { name = "dap" },
        },
    })
    --[[ -- cmp_dap
    cmp.setup {
        enabled = function()
            return vim.bo.buftype ~= "prompt" or require("cmp_dap").is_dap_buffer()
        end
    } ]]

    return true
end
