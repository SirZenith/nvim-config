local user = require "user"
local lsp_status = require "lsp-status"

user.plugin.lsp_status = {
    __new_entry = true,
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

return function()
    user.lsp.on_attach_callbacks:append(lsp_status.on_attach)
    user.lsp.capabilities_settings:append(lsp_status.capabilities)

    lsp_status.register_progress()

    local cfg = user.plugin.lsp_status()
    cfg.kind_labels = user.lsp.kind_label()
    lsp_status.config(cfg)
end
