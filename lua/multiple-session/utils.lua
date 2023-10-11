local core = require("core")
local static = require("multiple-session.static")

local session_dir = function()
	return static.config.session_dir(core.file.root_path(static.config.root_pattern))
end

local session_path = function(session_name)
	return string.format("%s/%s/%s.vim", session_dir(), session_name, session_name)
end

return {
	session_dir = session_dir,
	session_path = session_path,
}
