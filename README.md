# astral.nvim

> AST-aware semantic diff navigator for Neovim.

Navigate your code changes as **semantic events** - not line hunks.
Instead of seeing what lines changed, you see what *concepts* changed.
function signature, new symbols, moved blocks, dependency shifts.

## The Problem

`git diff` shows you *lines* `difftastic` get closer, but they are passive viewers.
You can't navigate them, act on them, or build a review session around them from inside your editor.

**astral.nvim** brings the missing editorial layer: keyboard-driven, fully local, no cloud, no AI - just you and your code.

## Features

- AST-aware diffing - understands your code structure, not just text
- Semantic event list - see `function signature changed`, not `line 42 modified`
- Keyboard-driven navigation - jump between events with `]s` / `[s`
- Visual timeline - local HTML report, no server, no build step
- Fully local - no cloud, no telemetry, no AI

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

## Keybindings

| Key | Action |
|-----|--------|
| `]s` | Jump to next semantic event |
| `[s` | Jump to previous semantic event |
| `q` | Close the astral panel |

## Status

> ⚠️ This plugin is in early development. Expect breaking changes.

Current stage: **MVP in progress**

## Roadmap

- [ ] Core semantic diff engine (Python)
- [ ] Neovim quickfix integration (Lua)
- [ ] Event navigation keybindings
- [ ] Session persistence (`.astral` file)
- [ ] Multi-file diff support
- [ ] Telescope integration

## License

MIT
