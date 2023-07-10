local user = require "user"

user.option.o = {
    foldcolumn = '1', -- '0' is not bad
    foldlevel = 99,   -- Using ufo provider need a large value, feel free to decrease the value
    foldlevelstart = 99,
    foldenable = true,
}

user.plugin.nvim_ufo = {
    __new_entry = true,
    -- Time in millisecond between the range to be highlgihted and to be cleared
    -- while opening the folded line, `0` value will disable the highlight
    open_fold_hl_timeout = 0,
    -- A function as a selector for fold providers. For now, there are
    -- 'lsp' and 'treesitter' as main provider, 'indent' as fallback provider
    provider_selector = nil,
    -- After the buffer is displayed (opened for the first time), close the
    -- folds whose range with `kind` field is included in this option. For now,
    -- 'lsp' provider's standardized kinds are 'comment', 'imports' and 'region',
    -- run `UfoInspect` for details if your provider has extended the kinds.
    close_fold_kinds = {},
    -- A function customize fold virt text, see ### Customize fold text
    fold_virt_text_handler = nil,
    -- Enable a function with `lnum` as a parameter to capture the virtual text
    -- for the folded lines and export the function to `get_fold_virt_text` field of
    -- ctx table as 6th parameter in `fold_virt_text_handler`
    enable_get_fold_virt_text = false,
    -- Configure the options for preview window and remap the keys for current
    -- buffer and preview buffer if the preview window is displayed.
    -- Never worry about the users's keymaps are overridden by ufo, ufo will save
    -- them and restore them if preview window is closed.
    preview = {
        win_config = {
            -- The border for preview window,
            -- `:h nvim_open_win() | call search('border:')`
            border = "rounded",
            -- The winblend for preview window, `:h winblend`
            winblend = 12,
            -- The winhighlight for preview window, `:h winhighlight`
            winhighlight = "Normal:Normal",
            -- The max height of preview window
            maxheight = 20,
        },
        mappings = nil,
    }
}

return function()
    user.lsp.capabilities_settings:append {
        textDocument = {
            foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }
        }
    }

    require("ufo").setup(user.plugin.nvim_ufo())
end
