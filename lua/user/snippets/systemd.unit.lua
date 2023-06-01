# vim:ft=lua.snippet

local snip_filetype = "systemd"
local s = require("user.snippets.util")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
-- local psp = makers.psp
local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
-- local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

apsp("unitinit", [[
[Unit]
Description=${2:Simple Name}

[Service]
User=${3:username}
ExecStart=${4:executable-path}
Restart=on-failure

[Install]
WantedBy=${1:default.target}
]])

makers.finalize()
