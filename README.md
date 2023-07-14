# multiple-session.nvim

Provides multi-session management capabilities.

## Features

- auto load session
- auto save session
- switch between multiple sessions
- hooks on save and restore

## Dependencies

- [niuiic/core.nvim](https://github.com/niuiic/core.nvim)

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
	---@diagnostic disable-next-line
	on_session_to_save = function(session_dir) end,
	---@diagnostic disable-next-line
	on_session_saved = function(session_dir) end,
	---@diagnostic disable-next-line
	on_session_to_restore = function(session_dir) end,
	---@diagnostic disable-next-line
	on_session_restored = function(session_dir) end,
})
```

### Examples to store/restore breakpoints/quickfix/undo history

```lua
local config = function()
	local core = require("core")
	-- niuiic/dap-utils is required
	local dap_utils = require("dap-utils")
	require("multiple-session").setup({
		default_arg_num = 2,
		on_session_saved = function(session_dir)
			dap_utils.store_breakpoints(session_dir .. "/breakpoints")
			require("quickfix").store_qf(session_dir .. "/quickfix")
			vim.cmd("wundo" .. session_dir .. "/undo")
		end,
		on_session_restored = function(session_dir)
			if core.file.file_or_dir_exists(session_dir .. "/" .. "breakpoints") then
				dap_utils.restore_breakpoints(session_dir .. "/breakpoints")
			end
			if core.file.file_or_dir_exists(session_dir .. "/" .. "quickfix") then
				require("quickfix").restore_qf(session_dir .. "/quickfix")
			end
			if core.file.file_or_dir_exists(session_dir .. "/undo") then
				vim.cmd("rundo" .. session_dir .. "/undo")
			end
		end,
	})
end
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
