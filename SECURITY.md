# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

astral.nvim is a fully local Neovim plugin with **no network calls, no telemetry, and no external API dependencies**. However, if you discover a security vulnerability, please report it responsibly.

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Send a detailed report to the repository maintainer via GitHub's [private vulnerability reporting](https://github.com/xd0pa/astral.nvim/security/advisories/new)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Fix timeline**: Depends on severity (critical: 1 week, moderate: 1 month)

## Security Architecture

### Design Principles

1. **Fully local** — no network calls, no cloud dependencies
2. **No telemetry** — zero data leaves your machine
3. **No AI/LLM** — no external API calls
4. **Minimal surface** — Lua bridge is the only file that spawns subprocesses

### Threat Model

| Threat | Mitigation | Status |
|--------|-----------|--------|
| XSS via timeline HTML | All user data escaped with `textContent` / `escapeHtml()` | ✅ Mitigated |
| Command injection in subprocess | All arguments escaped with `vim.fn.shellescape()` | ✅ Mitigated |
| Path traversal via file input | Paths validated through git root resolution | ✅ Mitigated |
| Malicious git ref | Passed as argument to `git show` (not shell-interpolated) | ✅ Mitigated |
| Binary file injection | Explicit `UnicodeDecodeError` handling in engine | ✅ Mitigated |
| Session file tampering | Session data is local-only; no trust boundary crossed | ✅ Accepted |

### Known Limitations

- **Session file (`.astral`)** is stored as plain JSON in the git root. An attacker with write access to your filesystem could modify it. This is not considered a vulnerability since they already have filesystem access.
- **Timeline HTML** is generated as a temporary file in the OS temp directory. On shared systems, another user with access to `/tmp` could theoretically read it. This is a low-risk, local-only exposure.

## Best Practices for Users

1. Keep Neovim updated to >= 0.9.0
2. Use the plugin only on trusted repositories
3. Review the Python dependencies in `python/requirements.txt` before running `:AstralInstall`
4. Do not modify the `.astral` session file manually

## Security Changelog

| Date | Change |
|------|--------|
| 2025-04 | Added XSS prevention to timeline HTML (textContent over innerHTML) |
| 2025-04 | Added Content Security Policy to timeline template |
| 2025-04 | Fixed command injection in `:AstralInstall` (shell escaping) |
| 2025-04 | Removed duplicate imports and test comments from production code |
