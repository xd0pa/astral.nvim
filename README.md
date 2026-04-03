# ⬡ astral.nvim

> **AST-aware semantic diff navigator for Neovim.**

<p align="center">
  <img src="assets/logo2.png" width="120" alt="astral.nvim logo">
</p>

🌐 [English](README.md) | [Español](README.es.md)

---

Navigate your code changes as **semantic events** — not line hunks.
Instead of seeing what lines changed, you see what *concepts* changed:
function signatures, new symbols, moved blocks, dependency shifts.

## The Problem

`git diff` shows you *lines*. `difftastic` gets closer, but it's a passive viewer.
You can't navigate it, act on it, or build a review session around it from inside your editor.

**astral.nvim** brings the missing editorial layer: keyboard-driven, fully local, no cloud, no AI — just you and your code.

## Features

- 🔍 **AST-aware diffing** — understands your code structure, not just text
- 📋 **Semantic event list** — see `function signature changed`, not `line 42 modified`
- ⌨️ **Keyboard-driven navigation** — jump between events with `<A-n>` / `<A-p>`
- 🏷️ **Event bookmarking** — session persistence across Neovim restarts
- 📊 **Visual timeline** — local HTML report with filtering and search, no server, no build step
- 🔭 **Telescope integration** — fuzzy search through semantic events
- 🔒 **Fully local** — no cloud, no telemetry, no AI
- 🛡️ **XSS-safe** — all user data is escaped before rendering in the timeline

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

| Language | Extension | Parser |
|----------|-----------|--------|
| Python | `.py` | LibCST |
| JavaScript | `.js`, `.jsx` | tree-sitter |
| TypeScript | `.ts`, `.tsx` | tree-sitter |
| Lua | `.lua` | tree-sitter |

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
| `:SemanticDiff [ref]` | Run semantic diff against a git ref (default: `HEAD~1`) |
| `:AstralInstall` | Install Python dependencies into Neovim data directory |
| `:AstralTimeline` | Open visual timeline in browser with filtering and search |
| `:AstralTelescope` | Fuzzy search semantic events via Telescope |

## Keybindings

| Key | Action |
|-----|--------|
| `<A-n>` | Jump to next semantic event |
| `<A-p>` | Jump to previous semantic event |
| `<CR>` | Jump to event location (inside astral window) |
| `q` | Close the astral panel |

## Configuration

```lua
require("astral").setup({
  default_ref = "HEAD~1",    -- Default git ref to diff against
  ui_style = "split",        -- UI presentation style
  python_path = nil,         -- Custom Python interpreter path (nil = auto-detect)
  keymaps = {
    next_event = "<A-n>",    -- Next semantic event
    prev_event = "<A-p>",    -- Previous semantic event
    close      = "q",        -- Close astral panel
  },
})
```

## Architecture

astral.nvim uses a **hybrid Lua + Python** architecture:

```
astral.nvim/
├── lua/astral/          # Lua layer (UI, config, session, navigation)
│   ├── init.lua         # Entry point, commands setup
│   ├── config.lua       # User configuration defaults
│   ├── bridge.lua       # ONLY file that calls Python subprocess
│   ├── ui.lua           # Floating window presentation
│   ├── navigator.lua    # Event navigation and keymaps
│   ├── session.lua      # Session persistence (.astral file)
│   └── telescope.lua    # Telescope fuzzy search integration
├── python/              # Python AST diff engines
│   ├── astral_engine.py # Entry point CLI
│   ├── ast_diff_python.py  # LibCST-based Python diff
│   ├── ast_diff_js.py      # tree-sitter JS/TS diff
│   └── ast_diff_lua.py     # tree-sitter Lua diff
├── web/                 # Static web assets
│   └── timeline.html    # Timeline template (rendered with session data)
├── doc/                 # Neovim help documentation
├── tests/               # Unit tests for diff engines
└── skills/              # AI agent skills for project conventions
```

### How It Works

1. **Lua layer** detects the current file and git ref
2. **Bridge** spawns a Python subprocess with the file path and ref
3. **Python engine** retrieves the old version via `git show`, parses both versions with the appropriate AST parser, and returns semantic events as JSON
4. **UI layer** displays events in a floating window with navigation
5. **Session** is saved to `.astral` in the git root for persistence

## Timeline

The `:AstralTimeline` command generates a local HTML report with:

- **Filter buttons** — show only ADDED, REMOVED, or MODIFIED events
- **Search input** — filter events by name or description
- **Responsive design** — works on mobile and desktop
- **Content Security Policy** — prevents XSS and external resource loading
- **Tokyo Night theme** — consistent with Neovim aesthetics

## Security

astral.nvim is designed to be fully local and secure:

- **No network calls** — all processing happens locally
- **XSS prevention** — all user-controlled data is HTML-escaped before rendering
- **Command injection protection** — all shell arguments are properly escaped
- **No telemetry** — zero data leaves your machine
- **No AI/LLM calls** — no external API dependencies

See [SECURITY.md](SECURITY.md) for the full security policy.

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
- [x] Timeline filtering and search
- [x] Security hardening (XSS prevention, input sanitization)
- [ ] Go support
- [ ] Class and method-level diff
- [ ] Diff against any branch
- [ ] Inline diff view

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute.

## License

MIT — see [LICENSE](LICENSE) for details.
