local user = require "user"
local wrap_with_module = require "user.utils".wrap_with_module

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

local function finalize(module)
    user.lsp.on_attach_callbacks:append(module.on_attach)
    user.lsp.capabilities_settings:append(module.capabilities)

    module.register_progress()

    local cfg = user.plugin.lsp_status()
    cfg.kind_labels = user.lsp.kind_label()

    module.config(cfg)
end

return wrap_with_module("lsp-status", finalize)
