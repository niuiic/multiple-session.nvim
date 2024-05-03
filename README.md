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
	-- used to search root path of the project
	-- if .git does not exist, current directory path would be used
	root_pattern = ".git",
	-- where to store session
	session_dir = function(project_root)
		return project_root .. "/.nvim/session"
	end,
	-- name of default session
	default_session = "default",
	-- whether to auto load session when neovim start
	auto_load_session = function(_, cur_session_path)
		if #vim.v.argv > 2 then
			return false
		end

		-- detect whether in a nested instance
		if vim.env.NVIM then
			return false
		end

		local core = require("core")
		if not core.file.file_or_dir_exists(cur_session_path) then
			return false
		end

		return true
	end,
	-- whether to auto save session when neovim exits
	auto_save_session = function(_, cur_session_path)
		if #vim.v.argv > 2 then
			return false
		end

		if vim.env.NVIM then
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
})
```

### Examples to store/restore breakpoints/watches/undo history/quickfix

```lua
local core = require("core")
local dap_utils = require("dap-utils")
require("multiple-session").setup({
	on_session_saved = function(session_dir)
		-- niuiic/dap-utils.nvim
		dap_utils.store_breakpoints(session_dir .. "/breakpoints")
		dap_utils.store_watches(session_dir .. "/watches")
		-- niuiic/quickfix.nvim
		require("quickfix").store(session_dir .. "/quickfix")
		vim.cmd("wundo " .. session_dir .. "/undo")
	end,
	on_session_restored = function(session_dir)
		if core.file.file_or_dir_exists(session_dir .. "/" .. "breakpoints") then
			dap_utils.restore_breakpoints(session_dir .. "/breakpoints")
		end
		if core.file.file_or_dir_exists(session_dir .. "/watches") then
			dap_utils.restore_watches(session_dir .. "/watches")
		end
		if core.file.file_or_dir_exists(session_dir .. "/" .. "quickfix") then
			require("quickfix").restore(session_dir .. "/quickfix")
		end
		if core.file.file_or_dir_exists(session_dir .. "/undo") then
			vim.cmd("rundo " .. session_dir .. "/undo")
		end
	end,
})
```

## Keymap

```lua
{
	{
		"<leader>ss",
		function()
			require("multiple-session").save_session()
		end,
		desc = "save session",
	},
	{
		"<leader>sr",
		function()
			require("multiple-session").restore_session()
		end,
		desc = "restore session",
	},
	{
		"<leader>sd",
		function()
			require("multiple-session").delete_session()
		end,
		desc = "delete session",
	},
}
```

## Notice

For users who use `noice.nvim` together, make sure to load `noice.nvim` at `VimEnter`(set `event = "VimEnter"`), but not at start.

> Maybe you need the same settings for nvim-ufo and other plugins.

For any arised problem, first try deleting the session file and rebuilding.
