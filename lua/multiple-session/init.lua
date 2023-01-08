local config = require("multiple-session.config")
local lib = require("multiple-session.lib")

local project_root = lib.root_pattern(config.root_pattern)
local session_dir = config.session_dir(project_root)
local last_session = config.default_session

local store_session = function(session_name)
	last_session = session_name
	local session_path = session_dir .. "/" .. session_name .. ".vim"
	vim.cmd("mks! " .. session_path)
	vim.notify("session is stored in " .. session_path, vim.log.levels.INFO, {
		title = "Session",
	})
end

local save_session = function(session_name)
	if lib.file_or_dir_exists(session_dir) == false then
		vim.cmd("!mkdir " .. session_dir)
	end

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

local load_session = function(session_name, notify_err)
	local session_path = session_dir .. "/" .. session_name .. ".vim"
	if lib.file_or_dir_exists(session_path) then
		last_session = session_name
		-- close all buffers
		local status = pcall(vim.cmd, "%bd")
		if status == false then
			vim.notify("some buffers are not saved", vim.log.levels.ERROR, {
				title = "Session",
			})
			return
		end
		-- load session
		vim.cmd("silent source " .. session_path)
		vim.notify('successfully load session "' .. session_name .. '"', vim.log.levels.INFO, {
			title = "Session",
		})
	else
		if notify_err == true then
			vim.notify("no session", vim.log.levels.ERROR, {
				title = "Session",
			})
		end
	end
end

local restore_session = function(session_name, notify_err)
	if session_name ~= nil then
		load_session(session_name, notify_err)
	else
		local session_list = {}
		for path, path_type in vim.fs.dir(session_dir) do
			if path_type == "file" then
				local sn = string.sub(path, 1, string.len(path) - string.len(".vim"))
				table.insert(session_list, sn)
			end
		end
		vim.ui.select(session_list, { prompt = "select session" }, function(choice)
			if choice ~= nil then
				load_session(choice, notify_err)
			end
		end)
	end
end

-- restore session at start
vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	callback = function()
		if config.auto_load_session then
			restore_session(config.default_session)
			vim.cmd("e")
		end
	end,
	nested = true,
})

-- save session at leave
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function()
		if config.auto_save_session then
			save_session(last_session)
		end
	end,
})
local enable_auto_save_session = function()
	config.auto_save_session = true
end
local disable_auto_save_session = function()
	config.auto_save_session = false
end

-- setup
local setup = function(new_config)
	config = vim.tbl_deep_extend("force", config, new_config or {})
	project_root = lib.root_pattern(config.root_pattern)
	session_dir = config.session_dir(project_root)
end

return {
	setup = setup,
	enable_auto_save_session = enable_auto_save_session,
	disable_auto_save_session = disable_auto_save_session,
	restore_session = restore_session,
	save_session = save_session,
}
