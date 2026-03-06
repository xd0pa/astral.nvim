-- lua/astral/ui.lua
-- Handles all visual presentation of semantic events in Neovim.

local M = {}

-- Stores references to the current floating window and buffer
local state = {
  buf = nil,
  win = nil,
}

-- Check if the floating window is currently open
function M.is_opne()
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

return M

