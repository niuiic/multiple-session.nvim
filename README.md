# multiple-session.nvim

Provides multi-session management capabilities.

## Features

- auto load session
- auto save session
- switch between multiple sessions

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
	-- whether to auto load session when neovim start
	auto_load_session = true,
	-- whether to auto load session at start when neovim opened with args
	force_auto_load = false,
	-- whether to auto save session when leave neovim
	auto_save_session = true,
	-- name of default session
	default_session = "default",
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
