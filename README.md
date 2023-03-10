# multiple-session.nvim

Provides multi-session management capabilities.

## Features

- auto load session
- auto save session
- switch between multiple sessions
- hooks on save and restore

## Dependencies

- [niuiic/niuiic-core.nvim](https://github.com/niuiic/niuiic-core.nvim)

## Config

```lua
-- default config
require("multiple-session").setup({
	-- where to store session
	session_dir = function(project_root)
		return project_root .. "/.nvim/session"
	end,
	-- used to search root path of the project
	-- if .git does not exist, current directory path would be used
	root_pattern = ".git",
	-- whether to auto load session when neovim start(if this session exists)
	auto_load_session = true,
	-- whether to auto load session at start when neovim opened with args
	force_auto_load = false,
	-- whether to auto save session when leave neovim(if this session exists)
	auto_save_session = true,
	-- whether to auto create session at leave if this session doesn't exist
	force_auto_save = false,
	-- name of default session
	default_session = "default",
	-- default arg number
	-- for neovim > v0.9, nvim command may have the default arg `--embed`
	-- in this case, you have to set this to 2 for triggering session restoration correctly on startup
	default_arg_num = 1,
	-- command to create directory
	create_dir = "mkdir -p",
	-- command to delete session file
	delete_session = "rm -rf",
	-- function to execute when session saved
	on_session_saved = function(session_dir) end,
	-- function to execute when session restored
	on_session_restored = function(session_dir) end,
	-- example
	-- on_session_saved = function(session_dir)
	-- 	require("trailblazer").save_trailblazer_state_to_file(session_dir .. "/" .. "trailBlazer")
	-- end,
	-- on_session_restored = function(session_dir)
	-- 	if require("niuiic-core").file.file_or_dir_exists(session_dir .. "/" .. "trailBlazer") then
	-- 		require("trailblazer").load_trailblazer_state_from_file(session_dir .. "/" .. "trailBlazer")
	-- 	end
	-- end,
})
```

## Keymap

```lua
-- for example
{
    { "<leader>ss", "<cmd>SaveSession<CR>", desc = "save session" },
    { "<leader>sr", "<cmd>RestoreSession<CR>", desc = "restore session" },
    { "<leader>sa", "<cmd>EnableAutoSaveSession<CR>", desc = "enable auto save session" },
    { "<leader>sA", "<cmd>DisableAutoSaveSession<CR>", desc = "disable auto save session" },
    { "<leader>sd", "<cmd>DeleteSession<CR>", desc = "delete session" },
}
```

## Notice

For users who use `noice.nvim` together, make sure to load `noice.nvim` at `VimEnter`(set `event = "VimEnter"`), but not at start.

> Maybe you need the same settings for nvim-ufo and other plugins.

For any arised problem, first try deleting the session file and rebuilding.
