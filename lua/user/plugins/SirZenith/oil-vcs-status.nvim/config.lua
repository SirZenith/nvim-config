local user = require "user"

user.plugin.oil_vcs_status_nvim = {
    __new_entry = true,
    status_symbol = {
        added                = "",
        copied               = "󰆏",
        deleted              = "",
        ignored              = "",
        modified             = "",
        renamed              = "",
        typechanged          = "󰉺",
        unmodified           = " ",
        unmerged             = "",
        untracked            = "",

        upstream_added       = "󰈞",
        upstream_copied      = "󰈢",
        upstream_deleted     = "",
        upstream_ignored     = " ",
        upstream_modified    = "󰏫",
        upstream_renamed     = "",
        upstream_typechanged = "󱧶",
        upstream_unmodified  = " ",
        upstream_unmerged    = "",
        upstream_untracked   = " ",
    },
    status_priority = {
        upstream_ignored     = 0,
        upstream_untracked   = 1,
        upstream_unmodified  = 2,

        upstream_copied      = 3,
        upstream_renamed     = 3,
        upstream_typechanged = 3,

        upstream_deleted     = 4,
        upstream_modified    = 4,
        upstream_added       = 4,

        upstream_unmerged    = 5,

        ignored              = 10,
        untracked            = 11,
        unmodified           = 12,

        copied               = 13,
        renamed              = 13,
        typechanged          = 13,

        deleted              = 14,
        modified             = 14,
        added                = 14,

        unmerged             = 15,
    }
}

return function()
    require "oil-vcs-status".setup(user.plugin.oil_vcs_status_nvim())
end
