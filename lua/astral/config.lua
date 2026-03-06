-- lua/astral/config.lua
-- Manges user configuration
-- Users can override any of these defaults in their setup() call.

local M = {}

M.defaults = {
  default_ref = "HEAD~1",
  keymaps = {
    next_event = "]s",
    prev_event = "[s",
    close = "q",
  },
  ui_style = "split",
  python_path = nil,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
