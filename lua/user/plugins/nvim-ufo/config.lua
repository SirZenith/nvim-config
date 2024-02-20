local user = require "user"

---@alias user.plugin.nvim_ufo.Provider
---| "lsp"
---| "treesitter"
---| "indent"

---@alias user.plugin.nvim_ufo.VirtTextContent { [1]: string, [2]: string }

-- Return a list of `{ content, hl_group }` tuple.
---@alias user.plugin.nvim_ufo.VirtTextHandler fun(virt_text: user.plugin.nvim_ufo.VirtTextContent[], line_num: integer, end_line_num: integer, width: integer, truncate: fun(s: string, len: integer): string): user.plugin.nvim_ufo.VirtTextContent[]

user.plugin.nvim_ufo = {
    __new_entry = true,
    -- Highligh text after its folding state toggled for given time.
    open_fold_hl_timeout = 0,
    -- Function which returns a list of folding provider names, plugin will try
    -- to invoke providers in returned order.
    ---@type fun(bufnr: number, filetype: string, buftype: string): user.plugin.nvim_ufo.Provider[]
    provider_selector = nil,
    -- After buffer is displayed for the first time, set folding range of listed
    -- types to folded.
    -- Currently, 'lsp' provider gives folding range of type 'comment', 'imports'
    -- and 'region'.
    -- Run `:UfoInspect` to see if your provider has extra kind labels.
    ---@type string[]
    close_fold_kinds = {},
    -- Function for customizing fold virt text.
    ---@type user.plugin.nvim_ufo.VirtTextHandler?
    fold_virt_text_handler = function(virt_text, line_num, end_line_num, width, truncate)
        local new_virt_text = {}
        local suffix = ("   %d"):format(end_line_num - line_num)
        local suf_width = vim.fn.strdisplaywidth(suffix)
        local target_width = width - suf_width

        local cur_width = 0
        for _, chunk in ipairs(virt_text) do
            local chunk_text = chunk[1]
            local chunk_width = vim.fn.strdisplaywidth(chunk_text)

            if target_width > cur_width + chunk_width then
                table.insert(new_virt_text, chunk)
            else
                chunk_text = truncate(chunk_text, target_width - cur_width)

                local hl_group = chunk[2]
                table.insert(new_virt_text, { chunk_text, hl_group })

                -- add padding if total chunk width is less than target width
                -- after truncation.
                chunk_width = vim.fn.strdisplaywidth(chunk_text)
                if cur_width + chunk_width < target_width then
                    suffix = suffix .. (" "):rep(target_width - cur_width - chunk_width)
                end

                break
            end

            cur_width = cur_width + chunk_width
        end

        table.insert(new_virt_text, { suffix, "MoreMsg" })

        return new_virt_text
    end,
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
    local ufo = require "ufo"

    local target = vim.o
    target.foldcolumn = "0"
    -- `manual` fold methd require a large fold level to keep fold folded as it
    -- was after fold range gets updated.
    target.foldlevel = 99
    target.foldlevelstart = 99

    user.lsp.capabilities_settings:append {
        textDocument = {
            foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }
        }
    }

    ufo.setup(user.plugin.nvim_ufo())
end
