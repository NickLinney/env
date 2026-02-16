# VERSION.md

## Version
v0.4.0

## Release Date
2026-02-16

## Status
Personal environment templates repository.
SemVer is used to create stable reference points for repeatable machine bootstraps and consistent repo conventions.

## What This Version Represents
`v0.4.0` establishes **Windows and macOS** as first-class supported platforms for **standards-aligned Python development baselines**.

This release focuses on cross-platform parity with the existing Debian Python bootstrap philosophy:

- explicit interpreter control
- minimal, auditable behavior
- safe to re-run (idempotent where applicable)
- no mandatory workflow tooling

It also normalizes macOS dotfiles pathing and adds a small local-development SSH helper.

## Included In v0.4.0

### Added — MacOS 15 (Sequoia) Python Default Setup (python.org installers)
- `Python/MacOS/MacOS_15/python_macos_new_setup.sh`
  - installs CPython 3.9–3.13 side-by-side under:
    - `/Library/Frameworks/Python.framework/Versions/`
  - enforces Python 3.12 as the default `python3` via `/usr/local/bin` symlinks
  - verifies installer integrity via python.org SHA256 checksums
  - does not modify shell configuration
  - does not install Poetry/uv/pipx or any global Python packages

- `Python/MacOS/MacOS_15/README.md`
  - quickstart and verification guidance
  - explains default interpreter selection behavior on macOS

### Changed — Windows Python baseline is tooling-neutral by default
- `Python/Windows/python_windows_new_setup.ps1`
  - ADR-aligned baseline: installs Python + pipx
  - installs no global tools by default (empty tool list)
  - maintains explicit Python 3.12 defaults

- `Python/Windows/python_poetry_preferences.ps1`
  - clarified as an optional preferences layer
  - installs/configures Poetry via pipx (per-project `.venv/`)
  - improves robustness for pipx pathing and verification output

### Changed — macOS dotfiles path normalization + local dev SSH helper
- `dotfiles/MacOS/15.6.1/` → `dotfiles/MacOS/MacOS_15/`
- `dotfiles/MacOS/MacOS_15/.zshrc`
  - adds `dev()` helper for SSH to local containers:
    - `user@127.0.0.1:2222`

## Compatibility / Expectations

### Debian 13 (trixie)
- Remains supported as in v0.3.0 (pyenv-based multi-version bootstrap)

### Windows
- Requires `winget` and the Windows `py` launcher strategy
- Baseline provides Python + pipx; Poetry is optional via preferences script

### MacOS 15 (Sequoia)
- Uses official python.org installers (universal2)
- Requires `sudo` for installer execution and `/usr/local/bin` symlink management
- Dotfiles remain templates, not mandatory system configuration

## Operational Notes
- This repo stores **templates and bootstrap scripts**, not machine state.
- **No secrets** should ever be committed.
- `.env` files are blocked by default; templates/examples are allowed.
