local multiple_session = require("multiple-session")
local utils = require("multiple-session.utils")
local static = require("multiple-session.static")

-- restore session at start
vim.api.nvim_create_autocmd("VimEnter", {
	pattern = "*",
	callback = function()
		local cur_session = multiple_session.cur_session()
		local cur_session_path = utils.session_path(cur_session)
		if not static.config.auto_load_session(cur_session, cur_session_path) then
			return
		end

		multiple_session.restore_session(cur_session)
	end,
	nested = true,
})

-- save session at leave
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	callback = function()
		local cur_session = multiple_session.cur_session()
		local cur_session_path = utils.session_path(cur_session)
		if not static.config.auto_save_session(cur_session, cur_session_path) then
			return
		end

		multiple_session.save_session(multiple_session.cur_session())
	end,
})
