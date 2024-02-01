return function()
    local ufo = require "ufo"
    local set = vim.keymap.set

    ---@param record table<integer, integer>
    ---@param offset integer
    ---@return integer new_level
    local function change_foldlevel_by(record, offset)
        local bufnr = vim.api.nvim_get_current_buf()
        local old_level = record[bufnr] or 0
        local new_level = old_level + offset
        if new_level < 0 then
            new_level = 0
        end

        record[bufnr] = new_level

        return new_level
    end

    ---@type table<integer, integer>
    local ufo_fold_level = {}

    -- nvim-ufo uses `manual` fold method, and require a relatively large
    -- `foldlevel` to keep folding state when folding range gets updated.
    -- Following key mappings allows toggling folds without changing `foldlevel`.
    set("n", "zR", ufo.openAllFolds)
    set("n", "zM", ufo.closeAllFolds)

    set("n", "zr", function()
        ufo.closeFoldsWith(change_foldlevel_by(ufo_fold_level, 1))
    end)
    set("n", "zm", function()
        ufo.closeFoldsWith(change_foldlevel_by(ufo_fold_level, -1))
    end)
end
