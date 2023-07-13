local user = require "user"

return function()
    user.lsp.capabilities_settings:append(
        require("cmp_nvim_lsp").default_capabilities()
    )

    -- Prerequest
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if not luasnip_ok then
        vim.notify("nvim-cmp initialization failed")
        return
    end

    -- Setup nvim-cmp.
    local cmp = require "cmp"

    local function has_words_before()
        local unpac = unpack or table.unpack
        local line, col = unpac(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
    end

    local mapping = {
        ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<cr>"] = cmp.mapping.confirm { select = true },
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-e>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["<C-y>"] = cmp.config.disable,
        ["<C-k>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        },
    }

    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
                --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                if luasnip_ok then
                    luasnip.lsp_expand(args.body) -- For `luasnip` users.
                end
                -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
                -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            end,
        },
        mapping = mapping or {},
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "path" },
            --{ name = "vsnip" }, -- For vsnip users.
            { name = "luasnip" },     -- For luasnip users.
            -- { name = "ultisnips" }, -- For ultisnips users.
            -- { name = "snippy" }, -- For snippy users.
        }, {
            { name = "buffer" },
        })
    })

    -- Use buffer source for `/` (if you enabled `native_menu`, this won"t work anymore).
    cmp.setup.cmdline("/", {
        sources = {
            { name = "buffer" }
        }
    })

    -- Use cmdline & path source for ":" (if you enabled `native_menu`, this won"t work anymore).
    cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
            { name = "path" }
        }, {
            { name = "cmdline" }
        })
    })
end
