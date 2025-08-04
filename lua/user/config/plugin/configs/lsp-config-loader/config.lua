local user = require "user"

return function()
    local panelpal = require "panelpal"
    local lsp_config_loader = require "lsp-config-loader"

    user.lsp = {
        __override = true,
        log_update_method = panelpal.PanelContentUpdateMethod.append,
        log_scroll_method = panelpal.ScrollMethod.bottom,
    }

    lsp_config_loader.setup(user.lsp())
end
