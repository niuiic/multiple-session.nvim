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
local get_buf_name = function(bufnr, root_path)
	return string.sub(vim.api.nvim_buf_get_name(bufnr), string.len(root_path) + 2)
end

local store_breakpoints = function(file_path)
	local core = require("niuiic-core")
	local root_path = core.file.root_path()

	local breakpoints = require("dap.breakpoints").get()
	breakpoints = core.lua.table.reduce(breakpoints, function(prev_res, cur_item)
		local buf_name = get_buf_name(cur_item.k, root_path)
		prev_res[buf_name] = cur_item.v
		return prev_res
	end, {})

	local text = vim.fn.json_encode(breakpoints)

	local file = io.open(file_path, "w+")
	if not file then
		return
	end
	file:write(text)
	file:close()
end

local restore_breakpoints = function(file_path)
	local core = require("niuiic-core")
	local root_path = core.file.root_path()

	if not core.file.file_or_dir_exists(file_path) then
		return
	end
	local file = io.open(file_path, "r")
	if not file then
		return
	end
	local text = file:read("*a")

	local breakpoints = vim.fn.json_decode(text)
	if breakpoints == nil then
		return
	end
	breakpoints = core.lua.list.reduce(vim.api.nvim_list_bufs(), function(prev_res, cur_item)
		local buf_name = get_buf_name(cur_item, root_path)
		if breakpoints[buf_name] ~= nil then
			prev_res[cur_item] = breakpoints[buf_name]
		end
		return prev_res
	end, {})

	core.lua.table.each(breakpoints, function(bufnr, breakpoint)
		core.lua.list.each(breakpoint, function(v)
			require("dap.breakpoints").set({
				condition = v.condition,
				log_message = v.logMessage,
				hit_condition = v.hitCondition,
			}, tonumber(bufnr), v.line)
		end)
	end)
end

return {
	config = function()
		local core = require("niuiic-core")
		require("multiple-session").setup({
			default_arg_num = 2,
			on_session_saved = function(session_dir)
				require("trailblazer").save_trailblazer_state_to_file(session_dir .. "/" .. "trailBlazer")
				store_breakpoints(session_dir .. "/breakpoints")
				require("quickfix").store_qf(session_dir .. "/quickfix")
				vim.cmd("wundo" .. session_dir .. "/undo")
			end,
			on_session_restored = function(session_dir)
				if core.file.file_or_dir_exists(session_dir .. "/" .. "trailBlazer") then
					require("trailblazer").load_trailblazer_state_from_file(session_dir .. "/" .. "trailBlazer")
				end
				if core.file.file_or_dir_exists(session_dir .. "/" .. "breakpoints") then
					restore_breakpoints(session_dir .. "/breakpoints")
				end
				if core.file.file_or_dir_exists(session_dir .. "/" .. "quickfix") then
					-- quickfix.nvim is required(https://github.com/niuiic/quickfix.nvim)
					require("quickfix").restore_qf(session_dir .. "/quickfix")
				end
				if core.file.file_or_dir_exists(session_dir .. "/undo") then
					vim.cmd("rundo" .. session_dir .. "/undo")
				end
			end,
		})
	end,
	keys = {
		{ "<leader>ss", "<cmd>SaveSession<CR>", desc = "save session" },
		{ "<leader>sr", "<cmd>RestoreSession<CR>", desc = "restore session" },
		{ "<leader>sa", "<cmd>EnableAutoSaveSession<CR>", desc = "enable auto save session" },
		{ "<leader>sA", "<cmd>DisableAutoSaveSession<CR>", desc = "disable auto save session" },
		{ "<leader>sd", "<cmd>DeleteSession<CR>", desc = "delete session" },
	},
	lazy = false,
	dependencies = { "niuiic/niuiic-core.nvim" },
}
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
