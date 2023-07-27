local user = require "user"
local snip_completion = require "user.snippets.cmd-snippet.cmp-source"

local cmp = require "cmp"
local luasnip = require "luasnip"
local lspkind = require "lspkind"
local mapping = require "user.plugins.hrsh7th.nvim-cmp.keybinding"

user.plugin.nvim_cmp = {
    __new_entry = true,
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
            col_offset = -1,
            side_padding = 0,
        },
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = mapping,
    sources = cmp.config.sources(
        {
            -- completion source registered in user configs
            { name = snip_completion.name },
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

return function()
    -- LSP hook
    user.lsp.capabilities_settings:append(
        require("cmp_nvim_lsp").default_capabilities()
    )

    local lspkind_cfg = user.plugin.lspkind()
    lspkind_cfg.maxwidth = 50

    local fmt_func = lspkind.cmp_format(lspkind_cfg)

    local cmp_cfg = user.plugin.nvim_cmp()
    cmp_cfg.formatting.format = function(entry, vim_item)
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

    cmp.setup.filetype("FineCmdlinePrompt", {
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        })
    })
end
