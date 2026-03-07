-- lua/astral/telescope.lua
-- Telescope integration for astral.nvim
-- Allows fuzzy searching through semantic events

local M = {}

function M.open()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    vim.notify("astral: Telescope is not installed", vim.log.levels.ERROR)
    return
  end

  local events = require("astral.navigator").get_events()

  if #events == 0 then
    vim.notify("astral: no events loaded, run :SemanticDiff first", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "astral — semantic events",
    finder = finders.new_table({
      results = events,
      entry_maker = function(event)
        local icon = event.type == "ADDED" and "+"
          or event.type == "REMOVED" and "-"
          or "~"
        return {
          value = event,
          display = string.format("%s [%s] %s — %s", icon, event.type, event.name, event.description),
          ordinal = event.name .. " " .. event.description,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local event = selection.value
        if event.line and event.line > 0 then
          vim.api.nvim_win_set_cursor(0, { event.line, 0 })
          vim.cmd("normal! zz")
        end
      end)
      return true
    end,
  }):find()
end

return M
