local core = require("niuiic-core")
local static = require("multiple-session.static")

local project_root = function()
	return core.file.find_root_path(static.config.root_pattern)
end
local session_dir = function()
	return static.config.session_dir(project_root())
end
local last_session = static.config.default_session
local get_session_path = function(session_name)
	return string.format("%s/%s/%s.vim", session_dir(), session_name, session_name)
end

local select_session = function(cb)
	local session_list = {}
	for path, path_type in vim.fs.dir(session_dir()) do
		if path_type == "directory" then
			for path2, path_type2 in vim.fs.dir(session_dir() .. "/" .. path) do
				if path_type2 == "file" then
					local sn = string.sub(path2, 1, string.len(path2) - string.len(".vim"))
					table.insert(session_list, sn)
				end
			end
		end
	end
	if #session_list == 0 then
		vim.notify("no session available", vim.log.levels.ERROR, {
			title = "Session",
		})
		return
	end
	vim.ui.select(session_list, { prompt = "select session" }, function(choice)
		if choice ~= nil then
			cb(choice)
		end
	end)
end

-- save session
local store_session = function(session_name)
	local cur_session_dir = session_dir() .. "/" .. session_name
	if core.file.file_or_dir_exists(cur_session_dir) == false then
		vim.cmd(string.format("!%s %s", static.config.create_dir, cur_session_dir))
	end
	last_session = session_name
	local session_path = get_session_path(last_session)
	vim.cmd("mks! " .. session_path)
	vim.notify("session is stored in " .. session_path, vim.log.levels.INFO, {
		title = "Session",
	})
	static.config.on_session_saved(cur_session_dir)
end

local save_session = function(session_name)
	if session_name ~= nil then
		store_session(session_name)
	else
		vim.ui.input({
			prompt = "Session name: ",
			default = last_session,
		}, function(input)
			if input == nil or input == "" then
				return
			end
			store_session(input)
		end)
	end
end

-- restore session
local load_session = function(session_name, notify_err)
	local session_path = get_session_path(session_name)
	if core.file.file_or_dir_exists(session_path) then
		last_session = session_name
		-- close all buffers
		local status = pcall(vim.cmd, "%bd")
		if status == false then
			vim.notify("some buffers are not saved", vim.log.levels.ERROR, {
				title = "Session",
			})
			return false
		end
		-- load session
		vim.cmd("silent source " .. session_path)
		vim.notify('successfully load session "' .. session_name .. '"', vim.log.levels.INFO, {
			title = "Session",
		})
		static.config.on_session_restored(session_dir() .. "/" .. session_name)
		return true
	else
		if notify_err == true then
			vim.notify("no session called " .. session_name, vim.log.levels.ERROR, {
				title = "Session",
			})
		end
		return false
	end
end

---@param session_name string | nil
---@param notify_err boolean | nil
---@return boolean
local restore_session = function(session_name, notify_err)
	if session_name ~= nil then
		return load_session(session_name, notify_err)
	else
		local success = false
		select_session(function(choice)
			if choice ~= last_session then
				save_session(last_session)
			end
			success = load_session(choice, notify_err)
		end)
		return success
	end
end

-- delete session
local remove_session = function(session_name)
	local cur_session_dir = session_dir() .. "/" .. session_name
	if core.file.file_or_dir_exists(cur_session_dir) then
		vim.cmd(string.format("!%s %s", static.config.delete_session, cur_session_dir))
		vim.notify("session " .. session_name .. " is deleted", vim.log.levels.INFO, {
			title = "Session",
		})
	else
		vim.notify("no session called " .. session_name, vim.log.levels.ERROR, {
			title = "Session",
		})
	end
end

local delete_session = function(session_name)
	if session_name ~= nil then
		remove_session(session_name)
	else
		select_session(function(choice)
			remove_session(choice)
		end)
	end
end

-- restore session at start
vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	callback = function()
		if static.config.force_auto_load ~= true and #vim.v.argv > static.config.default_arg_num then
			return
		end
		if static.config.auto_load_session then
			if restore_session(static.config.default_session) then
				local buf_name = vim.api.nvim_buf_get_name(0)
				if buf_name ~= nil and buf_name ~= "" then
					vim.cmd("e")
				end
			end
		end
	end,
	nested = true,
})

-- save session at leave
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function()
		if static.config.force_auto_load ~= true and #vim.v.argv > static.config.default_arg_num then
			return
		end
		if static.config.auto_save_session then
			local session_path = get_session_path(last_session)
			if core.file.file_or_dir_exists(session_path) ~= true and static.config.force_auto_save ~= true then
				return
			end
			save_session(last_session)
		end
	end,
})
local enable_auto_save_session = function()
	static.config.auto_save_session = true
end
local disable_auto_save_session = function()
	static.config.auto_save_session = false
end

-- setup
local setup = function(new_config)
	static.config = vim.tbl_deep_extend("force", static.config, new_config or {})
	last_session = static.config.default_session
end

return {
	setup = setup,
	enable_auto_save_session = enable_auto_save_session,
	disable_auto_save_session = disable_auto_save_session,
	restore_session = restore_session,
	save_session = save_session,
	delete_session = delete_session,
}
