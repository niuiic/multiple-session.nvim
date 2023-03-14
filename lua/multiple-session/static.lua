local config = {
	session_dir = function(project_root)
		return project_root .. ".nvim/session"
	end,
	root_pattern = ".git",
	auto_load_session = true,
	force_auto_load = false,
	auto_save_session = true,
	force_auto_save = false,
	default_session = "default",
	default_arg_num = 1,
	create_dir = "mkdir -p",
	delete_session = "rm -rf",
	---@diagnostic disable-next-line
	on_session_saved = function(session_dir) end,
	---@diagnostic disable-next-line
	on_session_restored = function(session_dir) end,
}

return { config = config }
