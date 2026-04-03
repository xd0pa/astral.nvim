# Contributing to astral.nvim

Thank you for your interest in contributing! This document covers everything you need to know.

## 🌐 Documentation / Documentación

This project maintains documentation in both English and Spanish:

- **English**: [README.md](README.md)
- **Español**: [README.es.md](README.es.md)

When adding new documentation, please update **both** files to keep them in sync.

## Development Setup

### Prerequisites

- Neovim >= 0.9.0
- Python >= 3.10
- Git

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/xd0pa/astral.nvim.git
   cd astral.nvim
   ```

2. Create a virtual environment and install dependencies:
   ```bash
   cd python
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

3. Link the plugin to your Neovim config (for lazy.nvim):
   ```lua
   {
     "/path/to/astral.nvim",  -- local path instead of GitHub
     config = function()
       require("astral").setup()
     end,
   }
   ```

## Running Tests

```bash
cd tests/python
pytest
```

Tests cover the Python, JavaScript, and Lua diff engines.

## Project Structure

```
astral.nvim/
├── lua/astral/          # Lua layer (UI, config, session, navigation)
├── python/              # Python AST diff engines
├── web/                 # Static web assets (timeline template)
├── doc/                 # Neovim help documentation
├── tests/               # Unit tests
└── skills/              # AI agent skills for project conventions
```

## Coding Standards

### Lua

- Use **2-space indentation** (not tabs)
- Follow the `M = {}; return M` module pattern
- Use `vim.notify()` for user feedback
- Use `vim.system()` for async subprocess calls (Neovim 0.9+)
- **Only `bridge.lua` may call Python** — this is a strict architectural rule

### Python

- Add **type hints** on all public functions
- Use `dataclass` for structured data
- Handle `ParserSyntaxError` gracefully — return empty results, never crash
- Use `os.path` or `pathlib` — no hardcoded paths
- All comments must be in **English**

### HTML/CSS

- **Inline CSS only** — no external stylesheets
- **Vanilla JavaScript only** — no frameworks
- Use `textContent` instead of `innerHTML` for user data (XSS prevention)
- Must be **responsive** — works on mobile and desktop

### Git Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add Go language support
fix: handle binary files in diff engine
docs: update Spanish README
test: add unit tests for class detection
chore: update requirements.txt
```

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes following the coding standards above
3. Run the test suite: `cd tests/python && pytest`
4. Update documentation if needed (both English and Spanish)
5. Create a PR with a clear description of the changes

## Adding a New Language

To add support for a new language (e.g., Go):

1. Create `python/ast_diff_go.py` following the pattern of existing engines
2. Implement the `diff(old_source, new_source) -> list[dict]` function
3. Add the language detection in `python/astral_engine.py`
4. Add tests in `tests/`
5. Update the supported languages table in both README files
6. Update `doc/astral.txt`

## Reporting Issues

- **Bugs**: Include Neovim version, Python version, steps to reproduce, and expected vs actual behavior
- **Features**: Describe the use case and why it would be valuable
- **Security**: See [SECURITY.md](SECURITY.md) — do NOT open public issues for vulnerabilities

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
