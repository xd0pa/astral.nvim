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

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local cwd = vim.fn.getcwd()
    local session = require("astral.session").load(cwd .. "/placeholder")
    if session and #session.events > 0 then
      require("astral.navigator").load_session(session)
      vim.notify(
        "astral: session loaded - " .. #session.events .. " event(s) from las diff",
        vim.log.levels.INFO
      )
    end
  end,
})

return M
