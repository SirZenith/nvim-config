local user = require "user"

user.plugin.nvim_cmp = {
    __new_entry = true,
}

return function()
    local cmp = require "cmp"
    local mapping = require "user.plugins.nvim-cmp.mapping"

    user.plugin.nvim_cmp = {
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
        )
    }

    local fmt_func

    local cmp_cfg = user.plugin.nvim_cmp()
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
