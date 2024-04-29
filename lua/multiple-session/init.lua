local core = require("core")
local static = require("multiple-session.static")
local utils = require("multiple-session.utils")

local cur_session = static.config.default_session

local select_session = function(cb)
	local session_list = {}
	for path, path_type in vim.fs.dir(utils.session_dir()) do
		if path_type == "directory" and core.file.file_or_dir_exists(utils.session_path(path)) then
			table.insert(session_list, path)
		end
	end

	if #session_list == 0 then
		vim.notify("No session available", vim.log.levels.WARN, {
			title = "Session",
		})
		return
	end

	vim.ui.select(session_list, { prompt = "Select session" }, function(choice)
		if choice ~= nil then
			cb(choice)
		end
	end)
end

-- save session
local store_session = function(session_name)
	cur_session = session_name

	local cur_session_dir = utils.session_dir() .. "/" .. session_name
	if not core.file.file_or_dir_exists(cur_session_dir) then
		core.file.mkdir(cur_session_dir)
	end

	static.config.on_session_to_save(cur_session_dir)

	vim.cmd("mks! " .. utils.session_path(cur_session))
	vim.notify("Session is stored in " .. utils.session_path(cur_session), vim.log.levels.INFO, {
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
			default = cur_session,
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
	if not core.file.file_or_dir_exists(utils.session_path(session_name)) then
		if notify_err == true then
			vim.notify("No session called " .. session_name, vim.log.levels.ERROR, {
				title = "Session",
			})
		end
		return false
	end

	cur_session = session_name

	-- close all buffers
	---@diagnostic disable-next-line
	local ok = pcall(vim.cmd, "%bd")
	if ok == false then
		vim.notify("Some buffers are not saved", vim.log.levels.ERROR, {
			title = "Session",
		})
		return false
	end

	static.config.on_session_to_restore(utils.session_dir())

	-- load session
	ok = pcall(vim.cmd, "silent source " .. utils.session_path(session_name))
	if ok then
		vim.notify('Successfully load session "' .. session_name .. '"', vim.log.levels.INFO, {
			title = "Session",
		})
	else
		vim.notify('Error occurs when loading session "' .. session_name .. '"', vim.log.levels.WARN, {
			title = "Session",
		})
	end

	static.config.on_session_restored(utils.session_dir() .. "/" .. session_name)

	return true
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
			if choice ~= cur_session then
				save_session(cur_session)
			end
			success = load_session(choice, notify_err)
		end)
		return success
	end
end

-- delete session
local remove_session = function(session_name)
	local cur_session_dir = utils.session_dir() .. "/" .. session_name

	if not core.file.file_or_dir_exists(cur_session_dir) then
		vim.notify(string.format("Session %s not found", session_name), vim.log.levels.ERROR, {
			title = "Session",
		})
		return
	end

	core.file.rmdir(cur_session_dir)
	vim.notify("Session " .. session_name .. " is deleted", vim.log.levels.INFO, {
		title = "Session",
	})
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

-- get current session
local get_cur_session = function()
	return cur_session
end

-- setup
local setup = function(new_config)
	static.config = vim.tbl_deep_extend("force", static.config, new_config or {})
	cur_session = static.config.default_session
end

return {
	setup = setup,
	restore_session = restore_session,
	save_session = save_session,
	delete_session = delete_session,
	cur_session = get_cur_session,
}
