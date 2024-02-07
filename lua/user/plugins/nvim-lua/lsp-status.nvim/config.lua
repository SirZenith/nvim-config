local user = require "user"

user.plugin.lsp_status = {
    __new_entry = true,
    kind_labels = {},
    current_function = true,
    show_filename = false,
    diagnostics = true,
    indicator_separator = "",
    component_separator = " ¦ ",
    indicator_errors = "%#LspStatusIndicatorErrors# %#lualine_c_normal#",
    indicator_warnings = "%#LspStatusIndicatorWarnings# %#lualine_c_normal#",
    indicator_info = "%#LspStatusIndicatorInfo# %#lualine_c_normal#",
    indicator_hint = "%#LspStatusIndicatorHint#󰌵 %#lualine_c_normal#",
    indicator_ok = "✨",
    spinner_frames = {
        "%#LspStatusSpinner1#󱑊 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱐿 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑀 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑁 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑂 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑃 %#lualine_c_normal#",

        "%#LspStatusSpinner2#󱑄 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑅 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑆 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑇 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑈 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑉 %#lualine_c_normal#",

        "%#LspStatusSpinner3#󱑊 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱐿 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑀 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑁 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑂 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑃 %#lualine_c_normal#",

        "%#LspStatusSpinner1#󱑄 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑅 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑆 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑇 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑈 %#lualine_c_normal#",
        "%#LspStatusSpinner1#󱑉 %#lualine_c_normal#",

        "%#LspStatusSpinner2#󱑊 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱐿 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑀 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑁 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑂 %#lualine_c_normal#",
        "%#LspStatusSpinner2#󱑃 %#lualine_c_normal#",

        "%#LspStatusSpinner3#󱑄 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑅 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑆 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑇 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑈 %#lualine_c_normal#",
        "%#LspStatusSpinner3#󱑉 %#lualine_c_normal#",
    },
    status_symbol = "󰣎 ",
    select_symbol = nil,
    update_interval = 100
}

return function()
    local lsp_status = require "lsp-status"

    user.lsp.on_attach_callbacks:append(lsp_status.on_attach)
    user.lsp.capabilities_settings:append(lsp_status.capabilities)

    lsp_status.register_progress()

    local cfg = user.plugin.lsp_status()
    cfg.kind_labels = user.lsp.kind_label()

    lsp_status.config(cfg)
end
