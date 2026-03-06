-- Entry point for astral.nvim
-- Neovim loads this file automatically on startup.
-- We only verify the plugin is available here, setup() is called by the user.

if vim.fn.has("nvim-0.9") == 0 then
  vim.notify("astral.nvim requires Neovim >= 0.9", vim.log.levels.ERROR)
  return
end
