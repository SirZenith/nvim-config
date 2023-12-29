local snip_filetype = "python"
local s = require("user-snippet.utils")
local makers = s.snippet_makers(snip_filetype)
local psp = makers.psp
local apsp = makers.apsp

apsp("ifmain", 'if __name__ == "__main__":\n    ${0:pass}')
apsp("withopen", [[
with open(${1:filename}, "${2:r}", encoding="utf8") as f:
    ${0:pass}
]])

psp("func", [[
def ${1:name}(${2}):
    ${0:pass}
]])
