local user = require "user"

user.plugin.oil_vcs_status_nvim = {
    __new_entry = true,
    status_symbol = {
        ["added"]       = "",
        ["copied"]      = "󰆏",
        ["deleted"]     = "",
        ["ignored"]     = "",
        ["modified"]    = "",
        ["renamed"]     = "",
        ["typechanged"] = "󰉺",
        ["unmodified"]  = " ",
        ["unmerged"]    = "",
        ["untracked"]   = "",

        ["upstream_added"]       = "󰈞",
        ["upstream_copied"]      = "󰈢",
        ["upstream_deleted"]     = "",
        ["upstream_ignored"]     = " ",
        ["upstream_modified"]    = "󰏫",
        ["upstream_renamed"]     = "",
        ["upstream_typechanged"] = "󱧶",
        ["upstream_unmodified"]  = " ",
        ["upstream_unmerged"]    = "",
        ["upstream_untracked"]   = " ",
    },
}

return function()
    require "oil-vcs-status".setup(user.plugin.oil_vcs_status_nvim())
end
