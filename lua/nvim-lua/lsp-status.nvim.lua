local user = require "user"
local lsp_status = require "lsp-status"

user.lsp_status = {
    kind_labels = {},
    current_function = true,
    show_filename = false,
    diagnostics = true,
    indicator_separator = "",
    component_separator = " ¦ ",
    indicator_errors = "❌",
    indicator_warnings = "🔶",
    indicator_info = "🔎",
    indicator_hint = "🔋",
    indicator_ok = "✨",
    spinner_frames = { "🌕", "🌔", "🌓", "🌒", "🌑", "🌘", "🌗", "🌖", "🌕" },
    status_symbol = " ⏻  ⮞",
    select_symbol = nil,
    update_interval = 100
}

user.lsp.on_attack_callbacks:append(lsp_status.on_attack)
user.lsp.capabilities_settings:append(lsp_status.capabilities)

return function()
    lsp_status.register_progress()

    lsp_status.config(user.lsp_status())
end
