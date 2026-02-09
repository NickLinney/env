# CHANGELOG

This repository uses Semantic Versioning (SemVer).

During `0.x`, structural changes may occur, but they are still documented
and versioned deliberately.

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