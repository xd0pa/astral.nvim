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

return M
