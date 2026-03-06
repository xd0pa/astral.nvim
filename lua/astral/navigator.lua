-- lua/astral/navigator.lua
-- Handles the :SemanticDiff command and event navigation.

local M = {}

-- Stores the current list of semantic events
local events = {}
local current_index = 0

function M.run(args)
	local filepath = vim.api.nvim_buf_get_name(0)
	local ref = (args ~= "") and args or require("astral.config").options.default_ref

	if filepath == "" then
		vim.notify("astral: no file open", vim.log.levels.WARN)
		return
	end

	vim.notify("astral: analyzing " .. vim.fn.fnamemodify(filepath, ":t") .. "...", vim.log.levels.INFO)

	require("astral.bridge").run(filepath, ref, function(data)
		events = data
		current_index = 1
		vim.schedule(function()
			M.show_events(ref)
			M.register_keymaps()
      require("astral.session").save(filepath, ref, data)
		end)
	end)
end

function M.show_events(ref)
	if #events == 0 then
		vim.notify("astral: no semantic changes found", vim.log.levels.INFO)
		return
	end

	require("astral.ui").show(events, ref)
end

function M.register_keymaps()
	local config = require("astral.config").options

	vim.keymap.set("n", config.keymaps.next_event, function()
		if #events == 0 then
			vim.notify("astral: no events loaded, run :SemanticDiff first", vim.log.levels.WARN)
			return
		end
		current_index = (current_index % #events) + 1
		local event = events[current_index]
		if event.line and event.line > 0 then
			local win = vim.fn.win_getid(vim.fn.winnr("#"))
			vim.api.nvim_win_set_cursor(win, { event.line, 0 })
			vim.cmd("normal! zz")
		end
	end, { silent = true, desc = "astral: next semantic event" })

	vim.keymap.set("n", config.keymaps.prev_event, function()
		if #events == 0 then
			vim.notify("astral: no events loaded, run :SemanticDiff first", vim.log.levels.WARN)
			return
		end
		current_index = ((current_index - 2) % #events) + 1
		local event = events[current_index]
		if event.line and event.line > 0 then
			local win = vim.fn.win_getid(vim.fn.winnr("#"))
			vim.api.nvim_win_set_cursor(win, { event.line, 0 })
			vim.cmd("normal! zz")
		end
	end, { silent = true, desc = "astral: previous semantic event" })
end

return M
