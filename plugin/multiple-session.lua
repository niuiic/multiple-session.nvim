local multiple_session = require("multiple-session")

vim.api.nvim_create_user_command("EnableAutoSaveSession", function()
	multiple_session.enable_auto_save_session()
end, {})

vim.api.nvim_create_user_command("DisableAutoSaveSession", function()
	multiple_session.disable_auto_save_session()
end, {})

vim.api.nvim_create_user_command("SaveSession", function()
	multiple_session.save_session()
end, {})

vim.api.nvim_create_user_command("RestoreSession", function()
	multiple_session.restore_session(nil, true)
end, {})

vim.api.nvim_create_user_command("DeleteSession", function()
	multiple_session.delete_session()
end, {})
