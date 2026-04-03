---
name: astral-template
description: >
  astral.nvim project skill covering template conventions, HTML timeline styling,
  code structure, and documentation standards.
  Trigger: When working on astral.nvim templates, HTML timeline, UI components,
  README files, documentation, or any visual/template changes.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Modifying the timeline HTML template (`web/timeline.html`)
- Creating or updating README files (English or Spanish)
- Adding new UI components or visual features
- Working on the astral.nvim theme, colors, or styling
- Creating documentation for the project

## Project Architecture

astral.nvim is a **hybrid Lua + Python** Neovim plugin with this structure:

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
├── tests/               # Unit tests for Python, JS, Lua engines
└── assets/              # Images, logos, etc.
```

## Critical Patterns

### Timeline HTML Template

The timeline template at `web/timeline.html` uses a **placeholder substitution** pattern:
- Lua reads the HTML file and replaces `__SESSION_DATA__` with JSON-encoded session data
- The template is written to a temp file and opened in the browser
- **Security**: Always escape user-controlled data before injecting into the template
- **Theme**: Uses Tokyo Night color palette as the default dark theme

### Tokyo Night Color Palette

All UI components MUST use these colors for consistency:

| Token | Hex | Usage |
|-------|-----|-------|
| `bg` | `#1a1b26` | Main background |
| `bg_dark` | `#16161e` | Nav/footer background |
| `bg_highlight` | `#1f2030` | Card/event background |
| `border` | `#2a2b3d` | Borders and dividers |
| `comment` | `#565f89` | Secondary text, labels |
| `fg` | `#c0caf5` | Primary text |
| `blue` | `#7aa2f7` | Links, accents, headers |
| `green` | `#9ece6a` | ADDED events, success |
| `red` | `#f7768e` | REMOVED events, errors |
| `orange` | `#e0af68` | MODIFIED events, warnings |
| `dark3` | `#3b4261` | Tertiary text, subtle elements |

### Semantic Event Types

All diff engines produce events with exactly these types:
- `ADDED` — new function/symbol detected
- `REMOVED` — function/symbol deleted
- `MODIFIED` — function/symbol changed

### Documentation Standards

- **README.md** — English documentation (primary)
- **README.es.md** — Spanish documentation (mirror)
- Both files MUST cross-link to each other at the top
- All code comments in source files MUST be in English
- Neovim help docs in `doc/astral.txt` follow `:help` format

### Python Diff Engines

Each language-specific diff module follows this contract:

```python
def diff(old_source: str, new_source: str) -> list[dict]:
    """Return list of {type, name, description, line} dicts."""
```

- Python engine uses **LibCST** for parsing
- JS/TS and Lua engines use **tree-sitter** for parsing
- All engines MUST handle parse errors gracefully (return empty list, not crash)

### Lua Architecture Rules

- `bridge.lua` is the **ONLY** Lua file that may call Python
- All other Lua files must communicate through the bridge
- Session files are stored at `{git_root}/.astral` (JSON format)
- Python venv is stored at `{stdpath("data")}/astral/.venv`

## Code Style

### Lua
- 2-space indentation (tabs in `init.lua` are legacy, use spaces)
- Use `vim.notify()` for user feedback
- Use `vim.system()` for async subprocess calls (Neovim 0.9+)
- Modules return `M` table pattern

### Python
- Type hints on all public functions
- `dataclass` for SemanticEvent
- Handle `ParserSyntaxError` gracefully
- No hardcoded paths — use `os.path` or `pathlib`

### HTML/CSS
- Inline CSS only (no external dependencies)
- No JavaScript frameworks — vanilla JS only
- Use `font-family: "JetBrains Mono", "Fira Code", monospace`
- Responsive: must work on mobile and desktop

## Commands

```bash
# Install dependencies (from Neovim)
:AstralInstall

# Run semantic diff
:SemanticDiff [ref]

# Open timeline in browser
:AstralTimeline

# Fuzzy search events
:AstralTelescope

# Run tests
cd tests/python && pytest
```

## Resources

- **Timeline Template**: `web/timeline.html`
- **Neovim Help**: `doc/astral.txt`
- **Python Engines**: `python/` directory
- **Lua Modules**: `lua/astral/` directory
