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
    local this_file = debug.getinfo(1, "S").source:sub(2)
    local plugin_root = vim.fn.fnamemodify(this_file, ":h:h:h")
    local python_dir = plugin_root .. "/python"

    vim.notify("astral: installing dependencies...", vim.log.levels.INFO)

    vim.system(
      { "bash", "-c", "cd " .. python_dir .. " && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt" },
      { text = true },
      function(result)
        vim.schedule(function()
          if result.code ~= 0 then
            vim.notify("astral: install failed\n" .. result.stderr, vim.log.levels.ERROR)
            return
          end
          vim.notify("astral: dependencies installed successfully!", vim.log.levels.INFO)
        end)
      end
    )
  end, {
    desc = "Install astral.nvim Python dependencies",
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
