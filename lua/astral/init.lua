-- lua/astral/init.lua
-- Main module for astral.nvim

local M = {}

function M.setup(opts)
	-- Load and merge user config with defaults
	require("astral.config").setup(opts)

	-- Command to run semantic diff
	vim.api.nvim_create_user_command("SemanticDiff", function(args)
		require("astral.navigator").run(args.args)
	end, {
		nargs = "?",
		desc = "Run an AST-aware semantic diff against a git ref",
	})

	-- Command to install Python dependencies
	vim.api.nvim_create_user_command("AstralInstall", function()
		local data_dir = vim.fn.stdpath("data") .. "/astral"
		local venv_path = data_dir .. "/.venv"

		local this_file = debug.getinfo(1, "S").source:sub(2)
		local plugin_root = vim.fn.fnamemodify(this_file, ":h:h:h")
		local requirements = plugin_root .. "/python/requirements.txt"

		vim.notify("astral: installing dependencies...", vim.log.levels.INFO)

		vim.system({
			"bash",
			"-c",
			"mkdir -p "
				.. data_dir
				.. " && python3 -m venv "
				.. venv_path
				.. " && "
				.. venv_path
				.. "/bin/pip install -r "
				.. requirements,
		}, { text = true }, function(result)
			vim.schedule(function()
				if result.code ~= 0 then
					vim.notify("astral: install failed\n" .. result.stderr, vim.log.levels.ERROR)
					return
				end
				vim.notify("astral: dependencies installed at " .. venv_path, vim.log.levels.INFO)
			end)
		end)
	end, {
		desc = "Install astral.nvim Python dependencies",
	})

	-- Command to  open the visual timeline in the browser
	vim.api.nvim_create_user_command("AstralTimeline", function()
		local cwd = vim.fn.getcwd()
		local session = require("astral.session").load(cwd .. "/placeholder")

		if not session or #session.events == 0 then
			vim.notify("astral: no session found, run :SemanticDiff first", vim.log.levels.WARN)
			return
		end

		-- Find the timeline template
		local this_file = debug.getinfo(1, "S").source:sub(2)
		local plugin_root = vim.fn.fnamemodify(this_file, ":h:h:h")
		local template_path = plugin_root .. "/web/timeline.html"

		-- Read the template file
		local f = io.open(template_path, "r")
		if not f then
			vim.notify("astral: could not read timeline template", vim.log.levels.ERROR)
			return
		end
		local html = f:read("*a")
		f:close()

		-- Replace the placeholder with real session data
		local json = vim.json.encode(session)
		html = html:gsub("__SESSION_DATA__", json)

		-- Write to a temp file
		local tmp = os.tmpname() .. ".html"
		local out = io.open(tmp, "w")
		if not out then
			vim.notify("astral: could not write timeline file", vim.log.levels.ERROR)
			return
		end
		out:write(html)
		out:close()

		-- Open in browser (cross-platform)
		local open_cmd
		if vim.fn.has("mac") == 1 then
			open_cmd = "open"
		elseif vim.fn.has("win32") == 1 then
			open_cmd = "start"
		else
			open_cmd = "xdg-open"
		end
		vim.system({ open_cmd, tmp }, { text = true })
		vim.notify("astral: timeline opened in browser", vim.log.levels.INFO)
	end, {
		desc = "Open semantic diff timeline in browser",
	})

	-- Command to open Telescope picker with semantic events
	vim.api.nvim_create_user_command("AstralTelescope", function()
		require("astral.telescope").open()
	end, {
		desc = "Open Telescope picker with semantic events",
	})

	-- Auto-load session on startup
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			local cwd = vim.fn.getcwd()
			local session = require("astral.session").load(cwd .. "/placeholder")
			if session and #session.events > 0 then
				require("astral.navigator").load_session(session)
				vim.notify(
					"astral: session loaded — " .. #session.events .. " event(s) from last diff",
					vim.log.levels.INFO
				)
			end
		end,
	})

	-- Confirm the plugin loaded correctly
	vim.notify("astral.nvim loaded!", vim.log.levels.INFO)
end

return M
