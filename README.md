# NickLinney/env

This repository contains **environment bootstrap scripts, dotfiles, and conventions**
for building **predictable, repeatable development environments** across platforms.

## What this repo is

This repo exists to:

* bootstrap new machines quickly and safely
* provide repeatable baseline conventions
* preserve explicit interpreter control
* avoid coupling projects to a single enforced workflow

It is a foundation: scripts and templates you can adopt, adapt, and extend.

---

## Quickstart Summary (At a Glance)

| Feature                              | Platform        | Quickstart Command |
|---------------------------------------|----------------|-------------------|
| Python baseline (pyenv)               | Debian 13      | `curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/Debian/trixie/python_trixie_new_setup.sh \| bash` |
| Python baseline                       | Windows        | `iwr -useb https://raw.githubusercontent.com/NickLinney/env/main/Python/Windows/python_windows_new_setup.ps1 \| iex` |
| Poetry preferences (optional layer)   | Windows        | `iwr -useb https://raw.githubusercontent.com/NickLinney/env/main/Python/Windows/python_poetry_preferences.ps1 \| iex` |
| Python baseline (python.org installers) | macOS 15     | `curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/MacOS/MacOS_15/python_macos_new_setup.sh \| bash` |
| Micro local LLM (interactive)         | Debian Trixie  | `curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-setup.sh \| bash` |
| Micro local LLM (CI / Docker)         | Debian Trixie  | `curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-noninteractive.sh \| bash` |

---

## Repository Structure

```text
.
├─ Python/
│  ├─ Debian/
│  │  └─ trixie/
│  ├─ MacOS/
│  │  └─ MacOS_15/
│  ├─ Windows/
│  └─ templates/
│
├─ micro/
│  └─ Debian/
│     └─ trixie/
│
├─ dotfiles/
│  └─ MacOS/
│     └─ MacOS_15/
│
├─ docs/
│  ├─ CONVENTIONS.md
│  └─ VERSIONING.md
│
├─ CHANGELOG.md
├─ VERSION.md
└─ LICENSE.md
````

---

# Quickstarts

Choose your platform and preferred execution style.

---

## Quickstart — Python Debian 13 (Trixie)

### A) Run directly from GitHub (no clone)

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/Debian/trixie/python_trixie_new_setup.sh | bash
```

### B) Run from a local clone (recommended)

```bash
git clone https://github.com/NickLinney/env.git
cd env
bash Python/Debian/trixie/python_trixie_new_setup.sh
```

After completion, open a **new shell** and verify:

```bash
python --version
which python
pyenv versions
pyenv global
```

Documentation:

* `Python/Debian/trixie/README.md`

---

## Quickstart — Python Windows Baseline Setup

### A) Run directly from GitHub (no clone)

```powershell
iwr -useb https://raw.githubusercontent.com/NickLinney/env/main/Python/Windows/python_windows_new_setup.ps1 | iex
```

### B) Run from a local clone (recommended)

```powershell
cd ~/Documents/Workspace
git clone https://github.com/NickLinney/env.git
cd env

.\Python\Windows\python_windows_new_setup.ps1
```

Notes:

* If execution policy blocks scripts:

  * `Set-ExecutionPolicy -Scope Process Bypass -Force`
* Open a new PowerShell session after running.

Documentation:

* `Python/Windows/README.md`

---

## Quickstart — Python Windows Poetry Preferences (Optional Layer)

### A) Run directly from GitHub

```powershell
iwr -useb https://raw.githubusercontent.com/NickLinney/env/main/Python/Windows/python_poetry_preferences.ps1 | iex
```

### B) Run from a local clone

```powershell
.\Python\Windows\python_poetry_preferences.ps1
```

This layer:

* Installs Poetry via pipx
* Configures per-project `.venv`
* Sets interpreter defaults for Poetry

---

## Quickstart — Python macOS 15 (Sequoia)

### A) Run directly from GitHub (no clone)

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/MacOS/MacOS_15/python_macos_new_setup.sh | bash
```

### B) Run from a local clone (recommended)

```bash
git clone https://github.com/NickLinney/env.git
cd env
bash Python/MacOS/MacOS_15/python_macos_new_setup.sh
```

Documentation:

* `Python/MacOS/MacOS_15/README.md`

---

## Quickstart — Micro Local LLM (Debian Trixie Interactive)

### A) Run directly from GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-setup.sh | bash
```

### B) Run from a local clone

```bash
bash micro/Debian/trixie/micro-local-llm-setup.sh
```

Installs:

* Micro
* Ollama
* `llm`
* `llm-ollama`
* `llm-micro`
* Keybindings (Alt-a, Alt-c)

Documentation:

* `micro/Debian/trixie/README.md`

---

## Quickstart — Micro Local LLM (Debian Trixie CI / Docker Provisioning)

### A) Run directly from GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-noninteractive.sh | bash
```

### B) Run from a local clone

```bash
bash micro/Debian/trixie/micro-local-llm-noninteractive.sh
```

Key behaviors:

* Requires root
* Targets non-root user home via `--target-user`
* Deterministic exit behavior (non-zero on failure)
* Supports `--skip-model-pull`
* Supports `--ollama-start-mode auto|background|never`
* Models are tag-based (not digest-pinned)

Documentation:

* `micro/Debian/trixie/README.md`
* `micro/Debian/trixie/AUTOMATION.md`

---

# Platform Entry Points

### Debian 13 (trixie)

* `Python/Debian/trixie/python_trixie_new_setup.sh`
* `Python/Debian/trixie/README.md`

### Windows

* `Python/Windows/python_windows_new_setup.ps1`
* `Python/Windows/python_poetry_preferences.ps1`
* `Python/Windows/README.md`

### macOS 15

* `Python/MacOS/MacOS_15/python_macos_new_setup.sh`
* `dotfiles/MacOS/MacOS_15/README.md`

### Micro (Debian Trixie)

* `micro/Debian/trixie/micro-local-llm-setup.sh`
* `micro/Debian/trixie/micro-local-llm-noninteractive.sh`
* `micro/Debian/trixie/README.md`
* `micro/Debian/trixie/AUTOMATION.md`

---

# Conventions and Versioning

* `docs/CONVENTIONS.md`
* `docs/VERSIONING.md`
* `CHANGELOG.md`
* `VERSION.md`

---

# License

MIT License — see `LICENSE.md`.
