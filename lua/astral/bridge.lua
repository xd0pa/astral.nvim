-- lua/astral/bridge.lua
-- The ONLY file in the Lua layer that knows Python exists.
-- Calls the Python engine as an external process and returns parsed JSON.

local M = {}

-- Returns the absolute path to the Python engine script
local function get_engine_path()
  -- debug.getinfo(1, "S").source gets the path of THIS file
  -- we then navigate relative to it to find the python folder
  local this_file = debug.getinfo(1, "S").source:sub(2)
  local plugin_root = vim.fn.fnamemodify(this_file, ":h:h:h")
  return plugin_root .. "/python/astral_engine.py"
end

function M.run(filepath, ref, callback)
  local engine = get_engine_path()
  local config = require("astral.config").options
  local python = vim.fn.expand(config.python_path or "python3")

  vim.system(
    { python, engine, "--file", filepath, "--ref", ref },
    { text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("astral error: " .. result.stderr, vim.log.levels.ERROR)
          return
        end
        local ok, data = pcall(vim.json.decode, result.stdout)
        if not ok then
          vim.notify("astral: failed to parse engine output", vim.log.levels.ERROR)
          return
        end
        callback(data)
      end)
    end
  )
end

return M
