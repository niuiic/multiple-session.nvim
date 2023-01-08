local config = {
	session_dir = function(project_root)
		return project_root .. "/.nvim/session"
	end,
	root_pattern = ".git",
	auto_load_session = true,
	force_auto_load = false,
	auto_save_session = true,
	default_session = "default",
}

return config
