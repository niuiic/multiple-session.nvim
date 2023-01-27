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
	-- in this case, you have to set this to 2 for trigger session restoration correctly
	default_arg_num = 1,
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
