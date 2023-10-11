local config = {
	root_pattern = ".git",
	session_dir = function(project_root)
		return project_root .. "/.nvim/session"
	end,
	default_session = "default",
	auto_load_session = function(_, cur_session_path)
		if #vim.v.argv > 2 then
			return false
		end

		local core = require("core")
		if not core.file.file_or_dir_exists(cur_session_path) then
			return false
		end

		return true
	end,
	auto_save_session = function(_, cur_session_path)
		if #vim.v.argv > 2 then
			return false
		end

		local core = require("core")
		if not core.file.file_or_dir_exists(cur_session_path) then
			return false
		end

		return true
	end,
	---@type fun(session_dir: string)
	on_session_to_save = function() end,
	---@type fun(session_dir: string)
	on_session_saved = function() end,
	---@type fun(session_dir: string)
	on_session_to_restore = function() end,
	---@type fun(session_dir: string)
	on_session_restored = function() end,
}

return { config = config }
