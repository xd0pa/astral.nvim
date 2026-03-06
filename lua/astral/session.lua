-- lua/astral/session.lua
-- Handles saving and loading diff sessions to disk
-- Sessions are stored as .astral files in the git root.

local M = {}

-- Find the git root starting from the give path
local function get_git_root(filepath)
	local result = vim.fn.systemlist("git -C " .. vim.fn.shellescape(filepath) .. " rev-parse --show-toplevel")
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return result[1]
end

function M.save(filepath, ref, events)
	local git_root = get_git_root(vim.fn.fnamemodify(filepath, ":h"))
	if not git_root then
		vim.notify("astral: not in a git repo, session not saved", vim.log.levels.WARN)
		return
	end

	local session = {
		ref = ref,
		filepath = filepath,
		events = events,
		saved_at = os.time(),
	}

	local session_file = git_root .. "/.astral"
	local f = io.open(session_file, "w")
	if not f then
		vim.notify("astral: could not save session", vim.log.levels.ERROR)
		return
	end

	f:write(vim.json.encode(session))
	f:close()

	vim.notify("astral: session saved to " .. session_file, vim.log.levels.INFO)
end

function M.load(filepath)
	local git_root = get_git_root(vim.fn.fnamemodify(filepath, ":h"))
	if not git_root then
		return nil
	end

	local session_file = git_root .. "/.astral"
	local f = io.open(session_file, "r")
	if not f then
		return nil
	end

	local content = f:read("*a")
	f:close()

	if content == "" then
		return nil
	end

	local ok, session = pcall(vim.json.decode, content)
	if not ok then
		vim.notify("astral: could not parse session file", vim.log.levels.WARN)
		return nil
	end

	return session
end

return M
