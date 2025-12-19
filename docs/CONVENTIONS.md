# docs/CONVENTIONS.md

This repository stores environment templates and dotfile-style configuration in a single place.

The primary goals are:
- Consistent structure across operating systems and tools
- Easy discovery and reuse
- Safe handling of `.env` patterns (templates only; never secrets)

## Core Rules

1. **No secrets**
   - Do not commit real secrets, tokens, or machine-specific credentials.
   - `.env` materials should be templates/examples only (e.g., `.env.example`).

2. **Prefer templates over live copies**
   - Files should be written as portable starting points.
   - If something must be machine-specific, document it clearly and avoid committing it.

3. **Document every directory that a human is expected to browse**
   - Each OS/version folder should include a short README when the contents are not self-evident.

## Repository Layout (High Level)

- `dotfiles/`  
  Dotfile-style templates organized by OS and OS version.

- Other top-level folders (as they emerge) should follow the same pattern:
  - group by system/tool first
  - keep paths predictable
  - include README when needed

## Dotfiles Structure

Dotfiles are stored under:

`dotfiles/<OS>/<OS_VERSION>/`

Example:
- `dotfiles/MacOS/15.6.1/`
  - `.zshrc`
  - `README.md`

### OS Naming

Use consistent OS names:
- `MacOS`
- `Linux`
- `Windows`

If a specific distro matters, create a deeper folder:
- `dotfiles/Linux/Debian/13/`
- `dotfiles/Linux/Ubuntu/24.04/`

## File Naming Guidance

- Keep filenames as close as possible to their real dotfile names:
  - `.zshrc`, `.vimrc`, `.gitconfig`, etc.

- When a file is intended as a template rather than a direct drop-in, use a clear extension:
  - `.template` / `.example` / `.sample`

Examples:
- `.env.example` (preferred)
- `.gitconfig.template`

## README Expectations (Per Folder)

A folder README should answer:
- What is this folder for?
- What OS/version/tool is it intended for?
- Any notable behaviors or assumptions?
- Minimal install/apply instructions

Keep it short and practical.

## Git Hygiene Notes

- Ignore OS and editor junk (e.g., `.DS_Store`, `Thumbs.db`).
- Keep commits scoped:
  - One OS/version payload + the docs that explain it is a good commit boundary.

