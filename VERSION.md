# VERSION.md

## Version
v0.2.0

## Release Date
2025-12-19

## Status
Personal environment templates repository.
SemVer is used to create stable reference points for my own machines and automation.

## What This Version Represents
This version adds the first macOS dotfiles payload and begins tightening repository hygiene
(indexing, guardrails, and documentation discipline) without introducing heavyweight governance.

## Included In v0.2.0
### Added
- `dotfiles/MacOS/15.6.1/`
  - `~/.zshrc` template
  - README describing purpose and usage

### Recommended Follow-ups (if included in this release)
- Repo-level `.gitignore` to prevent committing secrets and machine-local junk
- Minimal `CHANGELOG.md`
- Minimal `SECURITY.md`
- `CATALOG.md` / `docs/INDEX.md` for discoverability

## Compatibility / Expectations
- Templates are provided as examples and are adapted per machine.
- No secrets should be committed (use examples only).
- During `0.x`, breaking reorganizations may occur with MINOR bumps.
