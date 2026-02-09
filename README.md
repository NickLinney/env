# NickLinney/env

This repository contains **environment bootstrap scripts, dotfiles, and conventions**
for building **predictable, repeatable development environments** across platforms.

It is intentionally conservative, explicit, and automation-light:
- no hidden magic
- no opinionated frameworks forced on projects
- safe to re-run
- easy to audit

---

## Quickstart

Choose your platform:

### Debian 13 (trixie) — one-line install (no clone)

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/Debian/trixie/python_trixie_new_setup.sh | bash
````

After completion, open a **new shell** (or source your rc file) and verify:

```bash
python --version
which python
pyenv versions
pyenv global
```

---

### Windows — local clone (recommended)

```powershell
cd ~/Documents/Workspace
git clone https://github.com/NickLinney/env.git
cd env

.\Python\Windows\python_windows_new_setup.ps1
.\Python\Windows\python_poetry_preferences.ps1
```

Then follow the detailed guide:

* `Python/Windows/README.md`

---

### macOS — dotfiles template

See:

* `dotfiles/MacOS/15.6.1/README.md`

---

## What this repo is

This repo exists to:

* bootstrap new machines quickly and safely
* provide **repeatable baseline conventions** (paths, structure, repo hygiene)
* preserve **explicit interpreter control** across platforms
* avoid coupling projects to “one true workflow”

It is a **foundation**: scripts and templates you can adopt, adapt, and extend.

---

## Repository Structure (High Level)

```text
.
├─ Python/
│  ├─ Debian/
│  │  └─ trixie/                 # Debian 13 Python bootstrap (pyenv)
│  ├─ Windows/                   # Windows Python + Poetry setup
│  └─ templates/                 # Shared Python templates (.gitignore, cookbooks)
│
├─ dotfiles/
│  └─ MacOS/
│     └─ 15.6.1/                 # macOS zsh configuration template
│
├─ docs/
│  ├─ CONVENTIONS.md
│  └─ VERSIONING.md
│
├─ CHANGELOG.md
├─ VERSION.md
└─ LICENSE.md
```

---

## Platform Entry Points

### Debian 13 (trixie)

* Bootstrap script: `Python/Debian/trixie/python_trixie_new_setup.sh`
* Documentation: `Python/Debian/trixie/README.md`

What it does:

* installs build deps via `apt`
* installs/updates `pyenv` under `~/.pyenv`
* installs multiple CPython versions side-by-side
* sets a single explicit default via `pyenv global`
* configures shell init **idempotently** (`~/.bashrc`, `~/.zshrc`)

What it intentionally does **not** do:

* no Poetry
* no pipx-managed CLIs
* no project scaffolding

---

### Windows

* Setup scripts:

  * `Python/Windows/python_windows_new_setup.ps1`
  * `Python/Windows/python_poetry_preferences.ps1`
* Documentation: `Python/Windows/README.md`

What it provides:

* multiple Python versions via `winget` + the `py` launcher
* Poetry installed via `pipx`
* Poetry configured for per-project `.venv/`
* explicit Python 3.12 defaults (team baseline)

---

### macOS

* Dotfiles: `dotfiles/MacOS/15.6.1/`
* Documentation: `dotfiles/MacOS/15.6.1/README.md`

Focus:

* minimal zsh setup
* lightweight time tracking utilities
* small, auditable quality-of-life aliases (including `diffs` for git inspection)

---

## Conventions and Versioning

* `docs/CONVENTIONS.md` describes repo layout rules, naming patterns, and hygiene.
* `docs/VERSIONING.md` describes SemVer usage and branch/tag discipline.
* `CHANGELOG.md` records release history and meaningful changes.
* `VERSION.md` describes the current release snapshot in narrative form.

---

## License

MIT License — see `LICENSE.md`.
