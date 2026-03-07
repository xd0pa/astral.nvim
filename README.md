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
- Keyboard-driven navigation - jump between events with `<A-p>` / `<A-n>`
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

## Keybindings

| Key | Action |
|-----|--------|
| `<A-n>` | Jump to next semantic event |
| `<A-p>` | Jump to previous semantic event |
| `q` | Close the astral panel |

## Status

> ⚠️ This plugin is in early development. Expect breaking changes.

Current stage: **MVP complete**

## Roadmap

- [x] Core semantic diff engine (Python)
- [x] Neovim floating window UI
- [x] Event navigation with `<CR>`
- [x] Keybindings to cycle between events
- [x] Session persistence (`.astral` file)
- [x] Auto-load session on startup
- [x] Multi-language support (Python, JS, TS, Lua)
- [ ] Visual timeline (`web/timeline.html`)
- [ ] Telescope integration
- [ ] Go support

## License

MIT
