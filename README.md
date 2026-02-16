# NickLinney/env

This repository contains **environment bootstrap scripts, dotfiles, and conventions**
for building **predictable, repeatable development environments** across platforms.

It is intentionally conservative, explicit, and automation-light:

- no hidden magic
- no opinionated frameworks forced on projects
- safe to re-run
- easy to audit

---

## Repository Structure

```text
.
├─ Python/
│  ├─ Debian/
│  │  └─ trixie/                 # Debian 13 Python bootstrap (pyenv)
│  ├─ MacOS/
│  │  └─ MacOS_15/               # macOS 15 Python bootstrap (python.org installers)
│  ├─ Windows/                   # Windows Python baseline (+ optional Poetry preferences)
│  └─ templates/                 # Shared Python templates (.gitignore, cookbooks)
│
├─ dotfiles/
│  └─ MacOS/
│     └─ MacOS_15/               # macOS zsh configuration template
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

## Quickstart

Choose your platform and preferred execution style.

### Debian 13 (trixie)

**A) Run directly from GitHub (no clone)**

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/Debian/trixie/python_trixie_new_setup.sh | bash
````

**B) Run from a local clone (recommended)**

```bash
git clone https://github.com/NickLinney/env.git
cd env
bash Python/Debian/trixie/python_trixie_new_setup.sh
```

After completion, open a **new shell** (or source your rc file) and verify:

```bash
python --version
which python
pyenv versions
pyenv global
```

Documentation:

* `Python/Debian/trixie/README.md`

---

### Windows

#### Baseline (ADR-aligned): Python + pipx, no tools installed by default

**A) Run directly from GitHub (no clone)**

```powershell
iwr -useb https://raw.githubusercontent.com/NickLinney/env/main/Python/Windows/python_windows_new_setup.ps1 | iex
```

**B) Run from a local clone (recommended)**

```powershell
cd ~/Documents/Workspace
git clone https://github.com/NickLinney/env.git
cd env

.\Python\Windows\python_windows_new_setup.ps1
```

#### Optional preferences layer: Poetry via pipx (not part of the baseline)

**A) Run directly from GitHub (no clone)**

```powershell
iwr -useb https://raw.githubusercontent.com/NickLinney/env/main/Python/Windows/python_poetry_preferences.ps1 | iex
```

**B) Run from a local clone**

```powershell
.\Python\Windows\python_poetry_preferences.ps1
```

Notes:

* If you encounter script execution policy blocks, run PowerShell as a normal user and use:

  * `Set-ExecutionPolicy -Scope Process Bypass -Force`
* After running the preferences script, open a **new PowerShell session** so user environment variables take effect.

Documentation:

* `Python/Windows/README.md`

---

### macOS 15 (Sequoia)

#### Python baseline: python.org installers, explicit default interpreter

**A) Run directly from GitHub (no clone)**

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/MacOS/MacOS_15/python_macos_new_setup.sh | bash
```

**B) Run from a local clone (recommended)**

```bash
git clone https://github.com/NickLinney/env.git
cd env
bash Python/MacOS/MacOS_15/python_macos_new_setup.sh
```

Documentation:

* `Python/MacOS/MacOS_15/README.md`

#### Dotfiles template (optional)

Documentation:

* `dotfiles/MacOS/MacOS_15/README.md`

---

## What this repo is

This repo exists to:

* bootstrap new machines quickly and safely
* provide **repeatable baseline conventions** (paths, structure, repo hygiene)
* preserve **explicit interpreter control** across platforms
* avoid coupling projects to “one true workflow”

It is a **foundation**: scripts and templates you can adopt, adapt, and extend.

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

* Baseline script: `Python/Windows/python_windows_new_setup.ps1`
* Optional preferences: `Python/Windows/python_poetry_preferences.ps1`
* Documentation: `Python/Windows/README.md`

What it provides (baseline):

* multiple Python versions via `winget` + the `py` launcher
* `pipx` installed and ready (user-local)
* explicit Python 3.12 defaults (team baseline)
* no global tooling installed by default

Optional preferences layer:

* Poetry installed via `pipx`
* Poetry configured for per-project `.venv/`
* explicit Poetry interpreter defaults (`POETRY_PYTHON`, `PY_PYTHON=3.12`)

---

### macOS 15 (Sequoia)

Python baseline:

* Bootstrap script: `Python/MacOS/MacOS_15/python_macos_new_setup.sh`
* Documentation: `Python/MacOS/MacOS_15/README.md`

Dotfiles:

* Dotfiles: `dotfiles/MacOS/MacOS_15/`
* Documentation: `dotfiles/MacOS/MacOS_15/README.md`

Focus:

* minimal, auditable setup
* explicit interpreter control for Python
* small, safe quality-of-life functions/aliases (including `diffs` and `dev()`)

---

## Conventions and Versioning

* `docs/CONVENTIONS.md` describes repo layout rules, naming patterns, and hygiene.
* `docs/VERSIONING.md` describes SemVer usage and branch/tag discipline.
* `CHANGELOG.md` records release history and meaningful changes.
* `VERSION.md` describes the current release snapshot in narrative form.

---

## License

MIT License — see `LICENSE.md`.
