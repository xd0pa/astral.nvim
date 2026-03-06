-- lua/astral/init.lua
-- Main module for astral.nvim

local M = {}

function M.setup(opts)
  -- Load and merge user config with defaults
  require("astral.config").setup(opts)

  vim.api.nvim_create_user_command("SemanticDiff", function(args)
    require("astral.navigator").run(args.args)
  end, {
    nargs = "?",
    desc = "Run an AST-aware semantic diff against a git ref",
  })

  -- Confirm the plugin loaded correctly
  vim.notify("astral.nvim loaded!", vim.log.levels.INFO)
end

return M
