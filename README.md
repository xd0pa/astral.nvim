# ⬡ astral.nvim

<p align="center">
    <img src="assets/logo.png" width="120" alt="astral.nvim logo">
</p>

> AST-aware semantic diff navigator for Neovim.

Navigate your code changes as **semantic events** — not line hunks.
Instead of seeing what lines changed, you see what *concepts* changed:
function signatures, new symbols, moved blocks, dependency shifts.

## The Problem

`git diff` shows you *lines*. `difftastic` gets closer, but it's a passive viewer.
You can't navigate it, act on it, or build a review session around it from inside your editor.

**astral.nvim** brings the missing editorial layer: keyboard-driven, fully local, no cloud, no AI — just you and your code.

## Features

- 🔍 AST-aware diffing — understands your code structure, not just text
- 📋 Semantic event list — see `function signature changed`, not `line 42 modified`
- ⌨️ Keyboard-driven navigation — jump between events with `<A-n>` / `<A-p>`
- 🏷️ Event bookmarking — session persistence across Neovim restarts
- 📊 Visual timeline — local HTML report, no server, no build step
- 🔭 Telescope integration — fuzzy search through semantic events
- 🔒 Fully local — no cloud, no telemetry, no AI

## Requirements

- Neovim >= 0.9.0
- Python >= 3.10
- Git

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  "xd0pa/astral.nvim",
  config = function()
    require("astral").setup()
  end,
}
```

After installing, run this command inside Neovim to install Python dependencies:
```
:AstralInstall
```

This will automatically create a virtual environment and install all required
Python packages. You only need to run this once.

## Supported Languages

| Language | Extension |
|----------|-----------|
| Python | `.py` |
| JavaScript | `.js` `.jsx` |
| TypeScript | `.ts` `.tsx` |
| Lua | `.lua` |

## Usage

Open any file tracked by git and run:
```
:SemanticDiff
```

This diffs the current file against `HEAD~1` by default.
You can also pass a specific git ref:
```
:SemanticDiff HEAD~3
:SemanticDiff main
```

## Commands

| Command | Description |
|---------|-------------|
| `:SemanticDiff [ref]` | Run semantic diff against a git ref |
| `:AstralInstall` | Install Python dependencies |
| `:AstralTimeline` | Open visual timeline in browser |
| `:AstralTelescope` | Fuzzy search semantic events |

## Keybindings

| Key | Action |
|-----|--------|
| `<A-n>` | Jump to next semantic event |
| `<A-p>` | Jump to previous semantic event |
| `<CR>` | Jump to event location |
| `q` | Close the astral panel |

## Configuration
```lua
require("astral").setup({
  default_ref = "HEAD~1",
  ui_style = "split",
  python_path = nil,
  keymaps = {
    next_event = "",
    prev_event = "",
    close      = "q",
  },
})
```

## Status

> ⚠️ This plugin is in early development. Expect breaking changes.

Current stage: **v0.1.0**

## Roadmap

- [x] Core semantic diff engine (Python)
- [x] Neovim floating window UI
- [x] Event navigation with `<CR>`
- [x] Keybindings to cycle between events
- [x] Session persistence (`.astral` file)
- [x] Auto-load session on startup
- [x] Multi-language support (Python, JS, TS, Lua)
- [x] Visual timeline (`web/timeline.html`)
- [x] Telescope integration
- [ ] Go support
- [ ] Class and method support
- [ ] Diff against any branch

## License

MIT
