# CHANGELOG

This repository uses Semantic Versioning (SemVer).

During `0.x`, structural changes may occur, but they are still documented
and versioned deliberately.

---

## [0.5.0] - 2026-02-17

### Added

- Debian Trixie Micro editor local LLM assistant module:
  - `micro/Debian/trixie/micro-local-llm-setup.sh` (interactive setup)
  - `micro/Debian/trixie/micro-local-llm-noninteractive.sh` (non-interactive provisioning; root-required; target-user aware)
  - `micro/Debian/trixie/README.md`
  - `micro/Debian/trixie/AUTOMATION.md`

- Interactive setup script:
  - Installs Micro, Ollama, `llm`, `llm-ollama`, and `llm-micro`
  - Configures Micro keybindings
  - Supports optional model pull

- Non-interactive provisioning script:
  - Designed for Docker/CI contexts
  - Requires root
  - Targets non-root user via `--target-user`
  - Deterministic exit behavior (non-zero on error; exit code reflects error count, capped at 255)
  - Supports `--skip-model-pull`
  - Supports explicit Ollama lifecycle control (`--ollama-start-mode`)

### Notes

- Model pulls are tag-based (not digest-pinned); tags may change over time.
- Module is scoped to Debian Trixie.

---

## [0.4.0] - 2026-02-16
### Added
- MacOS 15 (Sequoia) (Sequoia) Python bootstrap (python.org installers):
  - `Python/MacOS/MacOS_15/python_macos_new_setup.sh`
  - installs CPython 3.9–3.13 side-by-side
  - enforces Python 3.12 as default via `/usr/local/bin` symlinks
  - checksum verification against python.org release pages
  - no Homebrew/pyenv, no project tooling, no dotfile writes
- MacOS 15 (Sequoia) Python documentation:
  - `Python/MacOS/MacOS_15/README.md`

### Changed
- Windows Python setup baseline is now ADR-aligned and tooling-neutral by default:
  - `Python/Windows/python_windows_new_setup.ps1` installs Python + `pipx` baseline
  - global CLI tools list defaults to empty (no Poetry by default)
  - Poetry workflow remains available as an optional preferences layer:
    - `Python/Windows/python_poetry_preferences.ps1`
- macOS dotfiles path normalized:
  - `dotfiles/MacOS/15.6.1/` → `dotfiles/MacOS/MacOS_15/`
- macOS zsh additions:
  - `dev()` helper for SSH into local containers (`user@127.0.0.1:2222`)

---

## [0.3.0] - 2026-02-09
### Added
- Debian 13 (trixie) Python bootstrap:
  - `Python/Debian/trixie/python_trixie_new_setup.sh`
  - pyenv-based multi-Python installation
  - idempotent shell initialization
  - no project tooling assumptions
- Debian 13 (trixie) documentation:
  - `Python/Debian/trixie/README.md`
- macOS zsh enhancement:
  - `diffs` alias for full git history inspection
- Repository documentation updates:
  - Expanded root `README.md`
  - Quickstart section with one-line installer

### Changed
- Root README now reflects:
  - Linux and macOS support as first-class citizens
  - explicit platform entry points
  - clarified design philosophy

---

## [0.2.0] - 2025-12-19
### Added
- `dotfiles/MacOS/15.6.1/`
  - `~/.zshrc` template
  - README

### Added (Repository Hygiene)
- `VERSION.md`
- `.gitignore` (cross-platform; blocks secrets, allows templates)

---

## [0.1.0] - 2025-12-19
### Added
- Initial semver-tagged baseline snapshot