-- lua/astral/ui.lua
-- Handles all visual presentation of semantic events in Neovim.

local M = {}

-- Stores references to the current floating window and buffer
local state = {
	buf = nil,
	win = nil,
}

-- Check if the floating window is currently open
function M.is_open()
	return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

-- Close the floating window if it's open
function M.close()
	if M.is_open() then
		vim.api.nvim_win_close(state.win, true)
		state.win = nil
		state.buf = nil
	end
end

-- Calculate the dimensions and position for the floating window
local function get_win_opts(num_events)
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.min(num_events + 4, math.floor(vim.o.lines * 0.4))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	return {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
end

function M.show(events, ref)
	-- Close any existing window first
	M.close()

	-- Create a new empty buffer for out window
	-- flase = not listed, true = scratch (temporary, no file)
	state.buf = vim.api.nvim_create_buf(false, true)

	-- Build the lines to display
	local lines = {}

	-- Header
	table.insert(lines, " astral - semantic diff against " .. ref)
	table.insert(lines, " " .. #events .. " change(s) found")
	table.insert(lines, "")

	-- One line per events
	for i, event in ipairs(events) do
		local icon = event.type == "ADDED" and "+" or event.type == "REMOVED" and "-" or "~"
		local line = string.format(" %s [%d] %s %s - %s", icon, i, event.type, event.name, event.description)
		table.insert(lines, line)
	end

	-- Write lines into the buffer
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

	-- Make the buffer unmodifiable
	vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = state.buf })

	-- Open the floating window
	state.win = vim.api.nvim_open_win(state.buf, true, get_win_opts(#events))

	-- Close with q
	local config = require("astral.config").options
	vim.keymap.set("n", config.keymaps.close, function()
		M.close()
	end, { buffer = state.buf, silent = true })

	-- Jump to event with <CR>
	vim.keymap.set("n", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(state.win)
		local line_idx = cursor[1]
		-- First 3 lines are header, events start at line 4
		local event_idx = line_idx - 3
		if event_idx < 1 or event_idx > #events then
			return
		end
		local event = events[event_idx]
		if event.line and event.line > 0 then
			M.close()
			vim.api.nvim_win_set_cursor(0, { event.line, 0 })
			vim.cmd("normal! zz")
		end
	end, { buffer = state.buf, silent = true })
end

return M
