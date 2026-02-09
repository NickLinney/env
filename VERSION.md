# VERSION.md

## Version
v0.3.0

## Release Date
2026-02-09

## Status
Personal environment templates repository.
SemVer is used to create stable reference points for repeatable machine bootstraps and consistent repo conventions.

## What This Version Represents
`v0.3.0` establishes **Debian 13 (trixie)** as a first-class supported platform in this repository by adding a **pyenv-based, multi-version Python bootstrap** that is intentionally minimal, explicit, and safe to re-run.

This release also upgrades the repo’s “front door” documentation:
- The root `README.md` now presents a **Quickstart** and clearer platform entry points.
- The repository structure and philosophy are made more explicit for day-1 usability.

Finally, this release includes a small macOS dotfiles refinement that improves day-to-day Git inspection ergonomics.

## Included In v0.3.0

### Added — Debian 13 (trixie) Python Bootstrap (pyenv)
- `Python/Debian/trixie/python_trixie_new_setup.sh`
  - Installs required build dependencies via `apt`
  - Installs/updates `pyenv` under `~/.pyenv`
  - Installs multiple CPython versions side-by-side
  - Sets a single, explicit default interpreter via `pyenv global`
  - Adds idempotent `pyenv init` blocks to:
    - `~/.bashrc`
    - `~/.zshrc`
  - Designed to be safe to re-run:
    - avoids duplicate shell config
    - skips already-installed Python versions
    - reasserts configured default

- `Python/Debian/trixie/README.md`
  - Local-clone instructions (recommended)
  - No-clone one-liner execution option
  - Verification steps
  - Explicit `venv`-first workflow guidance
  - Customization guidance (change versions/defaults in one place)

### Added — Root Documentation Improvements
- Root `README.md`
  - Adds a top-level **Quickstart** for Debian 13 (trixie)
  - Adds a one-line “curl | bash” installer for the Debian script
  - Clarifies repo structure and platform entry points
  - Re-states design philosophy: explicit, minimal, repeatable

### Changed — macOS Dotfiles Ergonomics
- `dotfiles/MacOS/15.6.1/.zshrc`
  - Adds `diffs` alias:
    - `git log --all --graph --patch --full-history`
  - (Also reflects the workspace alias adjustment present in the repo’s history.)

## Compatibility / Expectations

### Debian 13 (trixie)
- Intended baseline:
  - Debian 13 (testing / trixie) userland
  - User has `sudo` access for `apt` operations
- Installs:
  - `pyenv` into `~/.pyenv`
  - multiple CPython builds compiled locally (requires build deps)
- Expects:
  - user opens a new shell (or sources shell rc) after install

### Windows
- Uses `winget` + `py` launcher strategy for multi-version Python
- Poetry installed via `pipx` with per-project `.venv/` preference

### macOS
- Dotfiles are templates, not a mandatory system configuration
- File paths inside templates may be machine-specific and should be adapted

## Operational Notes
- This repo stores **templates and bootstrap scripts**, not machine state.
- **No secrets** should ever be committed.
- `.env` files are blocked by default; templates/examples are allowed.