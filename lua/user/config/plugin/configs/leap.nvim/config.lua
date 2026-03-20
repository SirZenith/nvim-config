return function()
    local leap = require "leap"

    for _, t in ipairs {
        { { "n", "x", "o" }, "s",  "<Plug>(leap-forward)",  "Leap forward to" },
        { { "n", "x", "o" }, "S",  "<Plug>(leap-backward)", "Leap backward to" },
        { { "n", "x", "o" }, "js", "<Plug>(leap-anywhere)", "Leap anywhere" },
    } do
        local modes, lhs, rhs, desc = unpack(t)
        for _, mode in ipairs(modes) do
            vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
        end
    end
end
