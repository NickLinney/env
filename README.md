# NickLinney/env

This repository contains **environment bootstrap scripts, dotfiles, and conventions**
for building **predictable, repeatable development environments** across platforms.

It is intentionally conservative, explicit, and automation-light:
- no hidden magic
- no opinionated frameworks forced on projects
- safe to re-run
- easy to audit

---

## Quickstart (One-Line Install — Debian 13 / Trixie)

If you are on **Debian 13 (trixie)** and want a working multi-Python environment immediately:

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/Debian/trixie/python_trixie_new_setup.sh | bash

```

After completion:

1. Open a **new shell** (or `source ~/.bashrc` / `source ~/.zshrc`)
2. Verify:

   ```bash
   python --version
   which python
   ```

This installs **pyenv**, multiple Python versions, and sets a clear default —
without Git, Poetry, or project tooling.

---

## Purpose

This repository exists to:

* Bootstrap new machines quickly and safely
* Preserve **explicit interpreter control**
* Avoid coupling projects to global tooling
* Provide **templates and conventions**, not mandates

The guiding idea is:

> *Environment setup should be boring, repeatable, and transparent.*

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
│     └─ 15.6.1/                 # macOS zsh configuration
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

* **Bootstrap script:**
  `Python/Debian/trixie/python_trixie_new_setup.sh`
* **Documentation:**
  `Python/Debian/trixie/README.md`

Installs:

* pyenv
* multiple CPython versions (side-by-side)
* idempotent shell initialization
* no Poetry, pipx, or project opinions

---

### Windows

* **Bootstrap:**
  `Python/Windows/python_windows_new_setup.ps1`
* **Poetry configuration:**
  `Python/Windows/python_poetry_preferences.ps1`
* **Documentation:**
  `Python/Windows/README.md`

Provides:

* multi-version Python via `py`
* pipx-managed Poetry
* per-project `.venv/`
* explicit Python 3.12 default

---

### macOS

* **Dotfiles:**
  `dotfiles/MacOS/15.6.1/`
* **Includes:**
  `.zshrc` template + README

Focus:

* minimal shell setup
* lightweight time tracking
* small, auditable quality-of-life aliases
  (including `diffs` for full git history inspection)

---

## Design Philosophy

Across all platforms:

* **Explicit over clever**
* **Templates over automation**
* **Idempotent scripts**
* **Human-readable documentation**
* **SemVer discipline**

This repo is a *foundation*, not a workflow mandate.

---

## Versioning & Releases

* Semantic Versioning (SemVer) is used
* `main` is the **ledger of tagged releases**
* Work happens on `release/<version>` branches
* Tags are applied **after merge to `main`**

See:

* `docs/VERSIONING.md`
* `CHANGELOG.md`

---

## License

MIT License — see `LICENSE.md`