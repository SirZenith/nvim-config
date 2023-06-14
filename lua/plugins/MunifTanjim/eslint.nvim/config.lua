local user = require "user"
local eslint = require "eslint"

user.eslint = {
    bin = 'eslint',
    code_actions = {
        enable = true,
        apply_on_save = {
            enable = true,
            types = { "directive", "problem", "suggestion", "layout" },
        },
        disable_rule_comment = {
            enable = true,
            location = "separate_line", -- 'separate_line' | `same_line`
        },
    },
    diagnostics = {
        enable = true,
        report_unused_disable_directives = false,
        run_on = "save", -- 'type' | 'save'
    },
}

return function()
    eslint.setup(user.eslint())
end
