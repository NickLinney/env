# docs/VERSIONING.md

This repository follows **Semantic Versioning (SemVer)** starting at **v0.1.0**.

SemVer format: `MAJOR.MINOR.PATCH` (e.g., `1.4.2`)

## How We Use Versions

This repo is a collection of templates and dotfiles. “Breaking” is primarily about:
- folder paths that automation or humans rely on
- naming conventions
- assumptions in README-guided workflows
- template formats that downstream scripts/tools expect

### PATCH (x.y.Z)
Use PATCH when changes are small and non-breaking, such as:
- typo fixes, comment updates, formatting cleanup
- minor README corrections
- small edits to a template that do not change the expected usage pattern
- small function/alias changes in shell configs that are unlikely to break expected behavior

If a change is “just a couple functions/aliases,” it’s probably a PATCH.

### MINOR (x.Y.z)
Use MINOR when adding features in a backward-compatible way, such as:
- adding new templates or new OS/version directories
- adding new optional sections to existing templates without changing existing defaults
- meaningful expansions that users are expected to adopt, but that do not break existing paths

Rule of thumb:
- **Adding a feature is a MINOR bump** unless it introduces breaking change.

### MAJOR (X.y.z)
Use MAJOR for breaking or sweeping changes, such as:
1. **Underlying technology changes** that break expected use  
   Example: a migration from one shell/tooling baseline to another that changes assumptions.
2. **Major refactors**  
   Example: reorganizing directory structure in a way that breaks links, scripts, or bookmarks.
3. **Deprecations** of files, directories, or major areas  
   Example: removing or superseding an OS folder tree or tool family.

## 0.x Guidance

While SemVer applies starting at v0.1.0, `0.x` is still an early lifecycle:
- Breaking changes can occur, but they should still be signaled clearly via MINOR (or MAJOR when warranted).
- Do not rely on “0.x means anything goes” as an excuse to avoid version discipline.

## Branching and Tags

- `main` is the stable, tagged line.
- Work for the next version happens on a `release/<next-version>` branch (e.g., `release/0.2.0`).
- Tags are applied to `main` after merge:
  - `v0.2.0`, `v0.2.1`, etc.

## Deciding Quickly: Patch vs Minor

Ask:
1. Did this change add something new that a user might adopt?  
   → MINOR

2. Did this change alter an existing behavior/path enough to surprise someone?  
   → MAJOR (or at minimum a breaking MINOR during `0.x`)

3. Is it just cleanup, corrections, or tiny adjustments?  
   → PATCH

