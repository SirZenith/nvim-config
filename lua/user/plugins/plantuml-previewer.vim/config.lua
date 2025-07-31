local user = require "user"
local fs_util = require "user.util.fs"

user.option.g = {
    ["plantuml_previewer#plantuml_jar_path"] = fs_util.path_join(user.env.APP_PATH(), "plantuml.jar")
}
