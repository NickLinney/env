This file is a merged representation of the entire codebase, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
docs/
  CONVENTIONS.md
  VERSIONING.md
dotfiles/
  MacOS/
    15.6.1/
      .zshrc
      README.md
Python/
  Debian/
    trixie/
      python_trixie_new_setup.sh
      README.md
  templates/
    gitignore/
      python-poetry.gitignore
    poetry/
      new_poetry_project_cookbook.md
  Windows/
    python_poetry_preferences.ps1
    python_windows_new_setup.ps1
    README.md
.gitignore
CHANGELOG.md
LICENSE.md
README.md
VERSION.md
```

# Files

## File: docs/CONVENTIONS.md
`````markdown
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
`````

## File: docs/VERSIONING.md
`````markdown
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
`````

## File: dotfiles/MacOS/15.6.1/README.md
`````markdown
# macOS 15.6.1 Dotfiles

This directory contains configuration files for my personal macOS development environment, including `~/.zshrc` and related shell configurations. The goal is to maintain a **minimal, UNIX-like workflow** on my primary working device, prioritizing simplicity, reliability, and efficiency.

---

## Overview

The environment is designed according to the principles of **pragmatic minimalism**:

- Leverage built-in system tools wherever possible.  
- Keep configuration simple and lightweight.  
- Ensure reliability and safety (e.g., prevent double clock-ins or data loss).  
- Preserve all historical records (append-only timesheets).  

This setup is intended for personal use and is tuned specifically for macOS 16.5.1, but it uses standard POSIX/macOS utilities and should work in similar UNIX-like environments.

---

## Features

### Workspace Navigation

- **Alias:** `workspace` — quickly navigate to the main development folder (`~/Documents/Workspace`).

### Time Tracking

A lightweight timesheet/timeclock system is built directly into the shell:

- Active timesheet file: `~/.timeclock`  
- Archived timesheets folder: `~/.timesheets/`  

#### Commands

- `timesheet` — Display the current active timesheet.  
- `timesheets` — List all archived timesheets.  
- `clockin` — Record a clock-in timestamp. Prevents double clock-ins and optionally allows specifying hours to close the previous session.  
- `clockout` — Record a clock-out timestamp. Prevents double clock-outs.  
- `clswk` — Close and archive the current timesheet. If a session is active, prompts to clock out before archiving.  
- `tscomm <comment>` — Append a free-text comment to the current timesheet.

**Implementation Notes:**

- The system is **append-only**; no entries are deleted.  
- When a new session is started, the most recent clock-in entry is used to compute elapsed time if necessary.  
- User prompts ensure accidental overwrites or invalid entries are avoided.

### Development Tools

- `awsprofile <profile>` — Switch AWS CLI profiles quickly.  
- `repomix` — Run the RepoMix Docker container for repository-based Markdown transformations.

---

## Philosophy

This environment is intentionally **minimal and focused**. It is not intended to provide a comprehensive suite of utilities, but rather to:

- Reduce cognitive overhead.  
- Enable lightweight, reliable workflow management.  
- Preserve historical records safely and transparently.  

The approach emphasizes **pragmatic minimalism**: do more with less, using tools already available in the system, with safety and reliability as first priorities.

---

## Installation and Usage

1. Copy `.zshrc` to `~/.zshrc`.  
2. Ensure that `~/.profile` exists and is sourced for base environment setup.  
3. Reload the shell configuration:

```bash
source ~/.zshrc
`````

## File: Python/Debian/trixie/python_trixie_new_setup.sh
`````bash
# ============================================================
# File: env/Python/Debian/trixie/python_trixie_new_setup.sh
# Purpose:
#   Bootstrap a Debian 13 (trixie) machine for multi-version Python using pyenv.
#   - Installs build deps
#   - Installs/updates pyenv
#   - Installs selected Python versions
#   - Sets a default (pyenv global)
#   - Adds idempotent shell init to ~/.bashrc and ~/.zshrc (if present)
#
# Notes:
#   - This script is designed to be safe to re-run.
#   - It uses sudo for apt operations.
#   - It intentionally does NOT install Poetry or enforce any project tooling.
# ============================================================

#!/usr/bin/env bash
set -euo pipefail

# ---------------------------#
# Configuration (edit me)    #
# ---------------------------#

# Versions to install (pyenv understands CPython versions like "3.12.7")
PYTHON_VERSIONS=(
  "3.9.21"
  "3.10.16"
  "3.11.11"
  "3.12.8"
  "3.13.1"
  # 3.14 is not released as stable at the time of writing; add when available (e.g. "3.14.0")
)

# Default interpreter after install (must exist in PYTHON_VERSIONS or already installed)
DEFAULT_PYTHON="3.12.8"

# Choose which shell rc files to configure. If a file doesn't exist, it will be created.
CONFIGURE_BASHRC="true"
CONFIGURE_ZSHRC="true"

# pyenv install location
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# ---------------------------#
# Helpers                    #
# ---------------------------#

step() { printf "\n==> %s\n" "$1"; }
info() { printf "    %s\n" "$1"; }
die()  { printf "\n[ERROR] %s\n" "$1" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

append_block_if_missing() {
  local file="$1"
  local marker="$2"
  local block="$3"

  mkdir -p "$(dirname "$file")" 2>/dev/null || true
  touch "$file"

  if grep -qF "$marker" "$file"; then
    info "Shell init already present in: $file"
  else
    info "Adding shell init to: $file"
    {
      echo ""
      echo "$block"
    } >> "$file"
  fi
}

require_sudo() {
  if ! have sudo; then
    die "sudo not found. Install sudo or run as a user with root privileges and modify the script accordingly."
  fi
  if ! sudo -n true 2>/dev/null; then
    info "sudo requires a password for apt operations."
  fi
}

# ---------------------------#
# 1) System dependencies      #
# ---------------------------#

step "Installing system dependencies (apt)"
require_sudo

sudo apt-get update -y

# Common pyenv build deps for CPython + venv support
sudo apt-get install -y --no-install-recommends \
  ca-certificates curl git \
  build-essential make \
  pkg-config \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libffi-dev liblzma-dev tk-dev xz-utils \
  llvm \
  python3-venv

info "System dependencies installed."

# ---------------------------#
# 2) Install/Update pyenv     #
# ---------------------------#

step "Installing/updating pyenv at $PYENV_ROOT"

if [ -d "$PYENV_ROOT/.git" ]; then
  info "pyenv already installed; updating..."
  git -C "$PYENV_ROOT" pull --ff-only
else
  info "pyenv not found; cloning..."
  git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
fi

# Optional: pyenv-virtualenv (useful but not required; kept lightweight)
if [ -d "$PYENV_ROOT/plugins/pyenv-virtualenv/.git" ]; then
  info "pyenv-virtualenv already installed; updating..."
  git -C "$PYENV_ROOT/plugins/pyenv-virtualenv" pull --ff-only
else
  info "Installing pyenv-virtualenv plugin..."
  git clone https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_ROOT/plugins/pyenv-virtualenv"
fi

# Ensure current shell can use pyenv immediately
export PYENV_ROOT="$PYENV_ROOT"
export PATH="$PYENV_ROOT/bin:$PATH"

if ! have pyenv; then
  die "pyenv command not found after installation. Check PATH and $PYENV_ROOT."
fi

info "pyenv version: $(pyenv --version)"

# ---------------------------#
# 3) Shell initialization     #
# ---------------------------#

step "Configuring shell initialization (idempotent)"

PYENV_INIT_MARKER="# >>> pyenv init (env repo) >>>"
PYENV_INIT_BLOCK="$PYENV_INIT_MARKER
export PYENV_ROOT=\"\$HOME/.pyenv\"
export PATH=\"\$PYENV_ROOT/bin:\$PATH\"
if command -v pyenv >/dev/null 2>&1; then
  eval \"\$(pyenv init -)\"
  # Enables pyenv-virtualenv if installed
  eval \"\$(pyenv virtualenv-init -)\"
fi
# <<< pyenv init (env repo) <<<"

if [ "$CONFIGURE_BASHRC" = "true" ]; then
  append_block_if_missing "$HOME/.bashrc" "$PYENV_INIT_MARKER" "$PYENV_INIT_BLOCK"
fi

if [ "$CONFIGURE_ZSHRC" = "true" ]; then
  append_block_if_missing "$HOME/.zshrc" "$PYENV_INIT_MARKER" "$PYENV_INIT_BLOCK"
fi

# ---------------------------#
# 4) Install Python versions  #
# ---------------------------#

step "Installing configured Python versions via pyenv"

# Improve reliability / speed: ensure pyenv has latest definitions (pyenv itself updated above)
# Build optimization: use all cores if available
if have nproc; then
  export MAKE_OPTS="-j$(nproc)"
fi

for ver in "${PYTHON_VERSIONS[@]}"; do
  if pyenv versions --bare | grep -qx "$ver"; then
    info "Python $ver already installed."
  else
    step "pyenv install $ver"
    # -s: skip if already installed (extra safety)
    pyenv install -s "$ver"
  fi
done

# ---------------------------#
# 5) Set default Python       #
# ---------------------------#

step "Setting default Python (pyenv global) to $DEFAULT_PYTHON"

if ! pyenv versions --bare | grep -qx "$DEFAULT_PYTHON"; then
  die "DEFAULT_PYTHON=$DEFAULT_PYTHON is not installed. Update DEFAULT_PYTHON or PYTHON_VERSIONS."
fi

pyenv global "$DEFAULT_PYTHON"

# Ensure shims are up to date
pyenv rehash

# ---------------------------#
# 6) Verification output      #
# ---------------------------#

step "Verification"

info "pyenv root: $PYENV_ROOT"
info "Installed versions:"
pyenv versions

info "Default (pyenv global):"
pyenv global

info "After opening a NEW shell, you should see:"
info "  python --version  (should match DEFAULT_PYTHON)"
info "  which python      (should resolve to pyenv shims)"

# Try a best-effort check in current shell (may still be influenced by existing PATH)
if have python; then
  info "Current shell python: $(python --version 2>&1 || true)"
fi

step "Done"
info "Next: open a new shell (or source ~/.bashrc / ~/.zshrc) and verify 'python --version'."
`````

## File: Python/Debian/trixie/README.md
`````markdown
# Debian 13 (trixie) — Python Setup Scripts

This directory contains bootstrap scripts for setting up **multiple Python versions** on **Debian 13 (trixie)** and selecting a **default interpreter** using `pyenv`.

The scope is intentionally minimal and conservative:

- install Python runtimes side-by-side
- establish a predictable default Python
- support a clean, explicit `venv`-first workflow

No project tooling (Poetry, pipx-managed CLIs, etc.) is configured here.

---

## What this setup gives you

After running the setup script:

- Multiple Python versions (e.g. 3.9 → 3.13) are available concurrently
- `python` resolves via `pyenv` to a clearly defined default
- You can explicitly choose interpreters per project
- Standard `python -m venv venv` workflows work as expected
- The script is safe to re-run on an existing machine

---

## Option A — Run from a local clone (recommended)

Clone the repository into your workspace:

```bash
git clone https://github.com/NickLinney/env.git
cd env
```

Run the bootstrap script:

```bash
bash env/Python/Debian/trixie/python_trixie_new_setup.sh
```

Open a **new shell** (recommended), or source your shell config:

```bash
# bash
source ~/.bashrc

# zsh
source ~/.zshrc
```

------

## Option B — Run directly from GitHub (no clone)

You may also execute the script directly from the repository:

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/Debian/trixie/python_trixie_new_setup.sh | bash
```

Notes:

- This will still install files into your home directory (`~/.pyenv`, shell rc files).
- You should review the script before running it this way.
- A new shell is still required afterward.

------

## Verification

After opening a new shell, verify the environment:

```bash
pyenv --version
pyenv versions
pyenv global
python --version
which python
```

Expected behavior:

- `python --version` matches the configured default in the script
- `which python` points to a `~/.pyenv/shims/...` path

------

## Creating a virtual environment (recommended workflow)

Create a project-local virtual environment using a specific interpreter:

```bash
python3.12 -m venv venv
source venv/bin/activate
python --version
```

Alternatively, set the interpreter for the current shell first:

```bash
pyenv shell 3.11.11
python --version
python -m venv venv
```

This keeps interpreter selection explicit and avoids hidden coupling.

------

## Script behavior notes

`python_trixie_new_setup.sh` performs the following actions:

- installs required build dependencies via `apt`
- installs or updates `pyenv` under `~/.pyenv`
- installs a configured list of CPython versions
- sets `pyenv global` to a chosen default
- adds **idempotent** `pyenv init` blocks to:
  - `~/.bashrc`
  - `~/.zshrc`

Re-running the script:

- will not duplicate shell config blocks
- will skip already-installed Python versions
- will reassert the configured default

------

## Customization

Edit the configuration section at the top of the script to change:

- which Python versions are installed
- which version is the default
- which shell rc files are modified

No other files need to be edited.

------

## Design philosophy

This setup prioritizes:

- explicitness over automation
- standard Python tooling over opinionated frameworks
- repeatability across machines
- minimal cognitive overhead

It is intended as a **foundation**, not a workflow mandate.
`````

## File: Python/templates/gitignore/python-poetry.gitignore
`````
# =====================================================================
# File: env/Python/templates/gitignore/python-poetry.gitignore
# Purpose: Baseline .gitignore for Python/Poetry projects (cross-platform)
# Note: No automation. You copy or merge this into projects when desired.
# =====================================================================

# ---- Python / Poetry ----
# Virtual environments
.venv/
venv/
ENV/
env/

# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class
*.pyd
*.so
*.dylib

# Packaging / build artifacts
build/
dist/
.wheels/
*.egg-info/
*.egg
.eggs/
pip-wheel-metadata/

# Test / coverage / tooling caches
.pytest_cache/
.coverage
.coverage.*
htmlcov/
.mypy_cache/
.pyre/
.pytype/
.ruff_cache/
.tox/
.nox/

# Logs, caches
*.log
.cache/

# IDE/editor settings (customize as needed)
.vscode/
.idea/

# OS junk files
.DS_Store
.AppleDouble
.LSOverride
Icon?
Thumbs.db
ehthumbs.db
Desktop.ini

# Environment files (keep templates like .env.example)
.env
.env.*
!.env.example
`````

## File: Python/templates/poetry/new_poetry_project_cookbook.md
`````markdown
# New Poetry Project Cookbook

This guide explains how to create a new Python project using [Poetry](https://python-poetry.org/) with the conventions used in our team.  
It assumes **Python and Poetry are already installed and configured** (for example, via our environment setup scripts).

---

## 1. Create the project

Navigate to your workspace directory (we use `~/Documents/Workspace`):

```powershell
cd ~/Documents/Workspace
poetry new <project-name> --src
cd <project-name>
````

This generates:

```
<project-name>/
├─ pyproject.toml      # project metadata and dependencies
├─ README.md           # starter project readme
├─ src/                # source code goes here
└─ tests/              # pytest-based tests
```

---

## 2. Add the baseline `.gitignore`

Copy in the standard `.gitignore` from our templates:

```powershell
copy ~/Documents/Workspace/env/Python/templates/gitignore/python-poetry.gitignore .\.gitignore
```

This ensures:

* virtual environments (`.venv/`)
* Python caches (`__pycache__/`)
* build artifacts (`dist/`, `*.egg-info/`)
* OS/editor junk (`.DS_Store`, `.vscode/`)

…are never accidentally committed.

---

## 3. Set the Python version (if needed)

By default, Poetry may declare the newest Python version (e.g., `>=3.13`).
If your project should use a different version (e.g., 3.12), edit the `[tool.poetry.dependencies]` section of `pyproject.toml`:

```toml
[tool.poetry.dependencies]
python = ">=3.12,<3.13"
```

This keeps the project pinned to Python 3.12.x.

---

## 4. Create the virtual environment

Poetry only creates the `.venv/` folder when you install dependencies:

```powershell
poetry env use 3.12   # or 3.13 if that’s your target
poetry install
```

This will:

* Create a `.venv/` in your project (because of our global preference `virtualenvs.in-project = true`).
* Sync dependencies from `pyproject.toml` (none yet on a brand-new project).

---

## 5. Verify the environment

Check which Python and venv you’re using:

```powershell
poetry env info
poetry run python -V
```

Output should show the correct Python version and the `.venv/` path inside your project.

---

## 6. Working inside the project

You have two options:

* **Without manual activation (recommended):**

  ```powershell
  poetry run python src/<project-name>/__init__.py
  poetry run pytest
  ```

* **With manual activation:**

  ```powershell
  .\.venv\Scripts\Activate.ps1   # PowerShell
  # or
  source .venv/bin/activate      # Linux/macOS
  ```

When activated, your prompt shows `(.venv)`, and all `python` / `pip` commands use the project’s interpreter.

---

## 7. Next steps

* Add dependencies:

  ```powershell
  poetry add requests
  poetry add --dev pytest
  ```

* Commit your project:

  ```powershell
  git init
  git add .
  git commit -m "chore: initialize poetry project"
  ```

---

### Summary

From empty folder to ready-to-code:

```powershell
cd ~/Documents/Workspace
poetry new myapp --src
cd myapp
copy ~/Documents/Workspace/env/Python/templates/gitignore/python-poetry.gitignore .\.gitignore
poetry env use 3.12
poetry install
poetry run python -V
```

You now have:

* A `src/` layout project.
* A `.venv/` in your project root.
* A `.gitignore` aligned with our standards.
* Everything ready for development and testing.
`````

## File: Python/Windows/python_poetry_preferences.ps1
`````powershell
# =====================================================================
# File: env/Python/Windows/python_poetry_preferences.ps1
# Purpose:
#   - Ensure pipx and Poetry exist (Poetry installed via pipx if missing)
#   - Configure Poetry to use per-project ".venv"
#   - Pin Poetry to Python 3.12 (POETRY_PYTHON) and set py launcher default (PY_PYTHON=3.12)
#   - Upgrade base pip/setuptools/wheel on Python 3.12
# NOTE:
#   - No .gitignore automation; template lives in the repo path above.
#   - Open a NEW PowerShell after running to pick up user env var changes.
# =====================================================================

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

function Step($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Info($m){ Write-Host "   $m" -ForegroundColor Gray }
function Die($m){ Write-Error $m; exit 1 }

# 0) Verify 'py' and locate Python 3.12
Step "Checking 'py' launcher and Python 3.12..."
if (-not (Get-Command py -ErrorAction SilentlyContinue)) { Die "'py' launcher not found. Install Python and re-run." }

$py312Path = $null
try { $py312Path = (& py -3.12 -c "import sys; print(sys.executable)") } catch {}
if (-not $py312Path) { Die "Python 3.12 not found by 'py'. Install 3.12 (e.g., winget install --id Python.Python.3.12 -e) and re-run." }
Info "Python 3.12 at: $py312Path"

# 1) Ensure pipx is present (user install)
Step "Ensuring pipx is installed..."
if (-not (Get-Command pipx -ErrorAction SilentlyContinue)) {
    Info "Installing pipx via Python 3.12 user site..."
    & py -3.12 -m pip install --user --upgrade pip
    & py -3.12 -m pip install --user pipx
    try { pipx ensurepath | Out-Null } catch { Info "pipx ensurepath will take effect in a new shell." }
    $userBase = (& py -3.12 -m site --user-base).Trim()
    $pipxBin  = Join-Path $userBase "Scripts"
    if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $pipxBin })) {
        $env:PATH = "$pipxBin;$env:PATH"
    }
}
Info "pipx version: $((pipx --version) 2>$null)"

# 2) Ensure Poetry via pipx
Step "Ensuring Poetry is installed via pipx..."
$poetryOk = $false
try { $null = poetry --version 2>$null; $poetryOk = $true } catch {}
if (-not $poetryOk) {
    Info "Installing Poetry..."
    pipx install poetry | Out-Null
    $null = poetry --version
}
Info "Poetry version: $((poetry --version) 2>$null)"

# 3) Configure Poetry defaults (per-project .venv)
Step "Configuring Poetry defaults (per-project .venv)..."
poetry config virtualenvs.in-project true

# 4) Pin interpreter defaults and upgrade base pip
Step "Setting user environment variables: POETRY_PYTHON and PY_PYTHON=3.12..."
setx POETRY_PYTHON "$py312Path" | Out-Null
setx PY_PYTHON "3.12" | Out-Null
Info "User env vars set. Open a NEW shell for them to take effect."

Step "Upgrading base pip/setuptools/wheel on Python 3.12..."
& py -3.12 -m pip install --upgrade pip setuptools wheel

Write-Host ""
Step "Done."
Write-Host "Poetry will default to Python 3.12 at: $py312Path" -ForegroundColor Green
Write-Host "Open a NEW PowerShell session to pick up POETRY_PYTHON and PY_PYTHON." -ForegroundColor Yellow
Write-Host "Per-project: 'poetry install' will create ./.venv (due to your global setting)." -ForegroundColor Gray
`````

## File: Python/Windows/python_windows_new_setup.ps1
`````powershell
<# 
Bootstrap Windows Python environment (multi-version) + pipx
- Installs selected CPython versions via winget (python.org builds)
- Creates a per-user py.ini to set default `py` launcher version
- Installs pipx (user-local), ensures PATH, and pins default interpreter
- Optionally installs common global CLI tools via pipx

Usage:
  - Run in a normal PowerShell session (no admin required).
  - Requires winget (App Installer). Windows 10/11.
#>

#---------------------------#
# Configuration (edit me)   #
#---------------------------#

$PythonVersions = @(
  '3.13',  # latest
  '3.12',
  '3.11',
  '3.10',
  '3.9'
)

$DefaultPythonMinor = '3.12'              # default for `py` (no switch) and pipx
$InstallGlobalTools = $true               # true or false
$GlobalTools       = @('poetry')  # install poetry, ruff, black, pdm, etc (change as desired)

#---------------------------#
# Script begins             #
#---------------------------#

$ErrorActionPreference = 'Stop'

function Assert-Winget {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is not available. Install 'App Installer' from the Microsoft Store or https://github.com/microsoft/winget-cli/releases, then re-run."
  }
}

function Install-PythonVersion {
  param(
    [Parameter(Mandatory=$true)][string]$MinorVersion
  )
  # Map minor -> winget ID (python.org maintained)
  $id =
    switch ($MinorVersion) {
      '3.13' { 'Python.Python.3.13' }
      '3.12' { 'Python.Python.3.12' }
      '3.11' { 'Python.Python.3.11' }
      '3.10' { 'Python.Python.3.10' }
      '3.9'  { 'Python.Python.3.9'  }
      default { throw "Unsupported minor version: $MinorVersion" }
    }

  # Check if already installed by asking the py launcher after first install;
  # for first run (no py yet), fall back to probing the standard install path.
  $already = $false
  $pyExists = Get-Command py -ErrorAction SilentlyContinue
  if ($pyExists) {
    $out = & py -0p 2>$null
    if ($out -match "3\.$($MinorVersion.Split('.')[1])") {
      $already = $true
    }
  } else {
    # Standard user-local path heuristic
    $short = $MinorVersion.Replace('.', '')
    $expected = Join-Path $env:LOCALAPPDATA "Programs\Python\Python3$short\python.exe"
    if (Test-Path $expected) { $already = $true }
  }

  if ($already) {
    Write-Host "[OK] Python $MinorVersion already present."
    return
  }

  Write-Host "[*] Installing Python $MinorVersion via winget ($id)..."
  # Non-interactive: accept agreements; exact match
  winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements | Out-Host
  Write-Host "[OK] Installed Python $MinorVersion."
}

function Set-PyDefault {
  param(
    [Parameter(Mandatory=$true)][string]$MinorVersion
  )
  $iniDir  = $env:LOCALAPPDATA
  if (-not (Test-Path $iniDir)) { New-Item -ItemType Directory -Force -Path $iniDir | Out-Null }
  $pyIni   = Join-Path $iniDir 'py.ini'
  $content = @"
[defaults]
python=$MinorVersion
"@
  Set-Content -Path $pyIni -Value $content -Encoding ASCII -Force
  Write-Host "[OK] Set default 'py' version to $MinorVersion in $pyIni"
}

function Ensure-Pipx {
  param(
    [Parameter(Mandatory=$true)][string]$MinorVersion
  )
  # Install pip & pipx into user site
  Write-Host "[*] Installing/Upgrading pip & pipx for Python $MinorVersion..."
  & py -$MinorVersion -m pip install --user -U pip pipx | Out-Host

  # Add pipx shims to PATH (persistent + current session)
  Write-Host "[*] Ensuring pipx PATH..."
  & py -$MinorVersion -m pipx ensurepath | Out-Host

  # The shim dir we expect on Windows
  $pipxBin = Join-Path $env:LocalAppData 'pipx\bin'
  if (-not ($env:Path -split ';' | Where-Object { $_ -eq $pipxBin })) {
    # Update current process PATH so `pipx` is immediately available
    $env:Path = "$pipxBin;$env:Path"
  }

  # Resolve the absolute path of the chosen interpreter for pipx-managed venvs
  $pyPath = & py -$MinorVersion -c 'import sys; print(sys.executable)'

  # Set user-level default for future pipx installs
  [Environment]::SetEnvironmentVariable('PIPX_DEFAULT_PYTHON', $pyPath, 'User')
  $env:PIPX_DEFAULT_PYTHON = $pyPath  # current session

  Write-Host "[OK] pipx ready. Default interpreter: $pyPath"
}

function Install-GlobalTools {
  param(
    [string[]]$Tools
  )
  foreach ($tool in $Tools) {
    try {
      Write-Host "[*] Installing/updating tool: $tool"
      & pipx install $tool --force | Out-Host
    } catch {
      Write-Warning "Failed to install $tool via pipx: $($_.Exception.Message)"
    }
  }
}

#--- Run ----------------------------------------------------------------------#

Assert-Winget

Write-Host "=== Installing CPython versions ==="
foreach ($v in $PythonVersions) { Install-PythonVersion -MinorVersion $v }

# Verify `py` launcher discovery
Write-Host "`n=== Discovered interpreters (py -0p) ==="
try { & py -0p | Out-Host } catch { Write-Warning "The 'py' launcher is not on PATH yet. Open a new shell if needed." }

# Set default `py` version
Set-PyDefault -MinorVersion $DefaultPythonMinor

# Install pipx and set defaults
Ensure-Pipx -MinorVersion $DefaultPythonMinor

# Optional: global tools
if ($InstallGlobalTools -and $GlobalTools.Count -gt 0) {
  Write-Host "`n=== Installing global CLI tools via pipx ==="
  Install-GlobalTools -Tools $GlobalTools
}

# Final checks
Write-Host "`n=== Final checks ==="
Write-Host "pipx version:"
try { & pipx --version | Out-Host } catch { Write-Warning "pipx not found on current PATH. Open a new PowerShell window." }

Write-Host "`nDetailed pipx state:"
try { & pipx list --verbose | Out-Host } catch { Write-Warning "pipx list failed; ensure a new shell after ensurepath." }

Write-Host "`nPython default (py):"
try { & py -V | Out-Host } catch { Write-Warning "py not found; ensure Python's launcher is on PATH or reopen shell." }

Write-Host "`nDone. If commands are missing, open a new PowerShell window to reload PATH."
`````

## File: Python/Windows/README.md
`````markdown
# Windows Environment Setup Scripts

This directory contains PowerShell scripts to bootstrap a Python + Poetry development environment on Windows.  
They are designed for repeatability when setting up new developer machines.

---

## Scripts

### 0. The Quick and Dirty
These instructions assume you are going to start by pulling down this repository first.

```powershell
cd ~/Documents/Workspace

git clone https://github.com/NickLinney/env.git

./env/Python/Windows/python_windows_new_setup.ps1
./env/Python/Windows/python_poetry_preferences.ps1

poetry new <project-name> --src

cd <project-name>
copy ~/Documents/Workspace/env/Python/templates/gitignore/python-poetry.gitignore .\.gitignore

poetry env use 3.12
poetry install
poetry run python -V
```

Keep reading if you want a more detailed breakdown of the commands.

### 1. `python_windows_new_setup.ps1`
Installs Python runtimes and the Windows `py` launcher.

- Uses **winget** to install multiple Python versions (e.g., 3.12, 3.13).  
- Ensures the `py` launcher is present (`py -0p` lists installed versions).  
- Provides a consistent base for development and for Poetry to build environments.

Run once on a fresh Windows system:

```powershell
.\python_windows_new_setup.ps1
````

---

### 2. `python_poetry_preferences.ps1`

Configures Poetry and related tooling.

* Installs **pipx** (if missing).
* Installs **Poetry** via pipx.
* Configures Poetry to always create **per-project `.venv/`** directories.
* Sets environment variables so Poetry defaults to **Python 3.12** (`POETRY_PYTHON`, `PY_PYTHON`).
* Upgrades `pip`, `setuptools`, and `wheel` in Python 3.12.

Run after `python_windows_new_setup.ps1`:

```powershell
.\python_poetry_preferences.ps1
```

⚠️ After running this script, open a **new PowerShell session** so the environment variables take effect.

---

## Project Creation Workflow

Once your environment is set up:

1. Navigate to your workspace:

   ```powershell
   cd ~/Documents/Workspace
   ```

2. Create a new Poetry project:

   ```powershell
   poetry new <project-name> --src
   cd <project-name>
   ```

3. Copy in the baseline `.gitignore`:

   ```powershell
   copy ~/Documents/Workspace/env/Python/templates/gitignore/python-poetry.gitignore .\.gitignore
   ```

4. Initialize the project environment:

   ```powershell
   poetry env use 3.12
   poetry install
   ```

5. Verify:

   ```powershell
   poetry run python -V
   ```

---

## Additional Resources

* [Poetry documentation](https://python-poetry.org/docs/)
* [Python downloads](https://www.python.org/downloads/windows/)
* [New Poetry Project Cookbook](../../templates/poetry/new_poetry_project_cookbook.md) — step-by-step guide for creating projects once your environment is ready.
`````

## File: .gitignore
`````
# =====================================================================
# env repo: dotfiles + .env templates (no secrets) + cross-platform junk
# =====================================================================

# --- macOS ------------------------------------------------------------
.DS_Store
.AppleDouble
.LSOverride
Icon?
._*
.Spotlight-V100
.Trashes
.fseventsd
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.VolumeIcon.icns

# --- Windows ----------------------------------------------------------
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
Desktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msix
*.msm
*.msp
*.lnk

# --- Linux / general --------------------------------------------------
*~
*.swp
*.swo
*.tmp
.nfs*
.Trash-*
.fuse_hidden*

# --- Editors / IDEs ---------------------------------------------------
.vscode/
.idea/
*.sublime-workspace
*.sublime-project
*.code-workspace

# --- Shell history / local state (never commit) -----------------------
.zsh_history
.zsh_sessions/
.bash_history
.lesshst
.python_history

# --- SSH / GPG / credentials (never commit) ---------------------------
.ssh/
.gnupg/
.netrc
.aws/
.azure/
.gcloud/
.kube/

# --- Real env files (do not commit secrets) ---------------------------
# Allow templates/examples; block actual env files.
.env
.env.*
!.env.example
!.env.template
!.env.sample
!.env.dist

# --- Language/tool caches (common) ------------------------------------
__pycache__/
*.py[cod]
.cache/
pip-wheel-metadata/
node_modules/
dist/
build/
coverage/
.envrc
.direnv/

# --- Archive/backup clutter -------------------------------------------
*.bak
*.old
*.orig
*.rej
*.save
*.zip
*.tar
*.tgz
*.gz
*.7z
`````

## File: LICENSE.md
`````markdown
MIT License

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
`````

## File: dotfiles/MacOS/15.6.1/.zshrc
`````
# ============================================================
# Base shell setup
# ============================================================

source ~/.profile

# ============================================================
# Ensure timesheets folder exists at shell startup
# ============================================================
mkdir -p ~/.timesheets

# ============================================================
# Workspace navigation
# ============================================================

alias ws='cd /Users/nrlin/Documents/Workspace'

# ============================================================
# Timeclock / Timesheet Management
# ============================================================
# Files:
#   ~/.timeclock      -> active timesheet (current session)
#   ~/.timesheets/    -> archived sessions
#
# Entry format:
#   Clocked in at  YYYY-MM-DD HH:MM
#   Clocked out at YYYY-MM-DD HH:MM
# ============================================================

# View current timesheet
timesheet() {
  if [[ -f ~/.timeclock ]]; then
    cat ~/.timeclock
  else
    echo "There is no current timesheet."
  fi
}

# List archived timesheets
alias timesheets='mkdir -p ~/.timesheets && ls -lah ~/.timesheets/'

# ----------------------------
# Clock in
# ----------------------------
# Prevents double-clockin.
# If already clocked in, prompts to close previous session or skip.
# ----------------------------
clockin() {
  local now now_epoch last_line last_time input seconds clockout_epoch clockout_time

  now="$(date +"%Y-%m-%d %H:%M")"
  now_epoch="$(date +%s)"

  # No active timesheet → simple clock-in
  if [[ ! -f ~/.timeclock ]]; then
    echo "Clocked in at $now"
    echo "Clocked in at $now" >> ~/.timeclock
    cd /Users/nrlin/Documents/Workspace
    return
  fi

  # Determine last entry
  last_line="$(tail -n 1 ~/.timeclock)"

  if [[ "$last_line" == Clocked\ in\ at* ]]; then
    last_time="${last_line#Clocked in at }"
    echo "You are already clocked in as of $last_time."
    echo -n "If you wish to start a new work session, enter the number of hours you worked last. ([0-99], 'q'uit, or 's'kip): "
    read input

    case "$input" in
      q|Q|quit|QUIT)
        echo "Aborted."
        return
        ;;
      s|S|skip|SKIP)
        echo "Starting new session without closing previous session."
        ;;
      *)
        # Validate numeric input: 0–99, up to 3 decimal places
        if [[ ! "$input" =~ ^([0-9]|[1-9][0-9])(\.[0-9]{1,3})?$ ]]; then
          echo "Invalid input. Must be a number between 0 and 99 with up to 3 decimal places."
          return 1
        fi

        # Convert hours → seconds
        seconds="$(printf "%.0f" "$(echo "$input * 3600" | bc -l)")"

        # Compute clockout time for the last clock-in
        clockout_epoch="$(( $(date -j -f "%Y-%m-%d %H:%M" "$last_time" +%s) + seconds ))"
        clockout_time="$(date -j -f "%s" "$clockout_epoch" +"%Y-%m-%d %H:%M")"

        # Close previous session
        echo "Clocked out at $clockout_time"
        echo "Clocked out at $clockout_time" >> ~/.timeclock
        ;;
    esac
  fi

  # Start new session
  echo "Clocked in at $now"
  echo "Clocked in at $now" >> ~/.timeclock
  cd /Users/nrlin/Documents/Workspace
}

# ----------------------------
# Clock out
# ----------------------------
# Prevents double-clockout.
# ----------------------------
clockout() {
  local now last_line last_time

  now="$(date +"%Y-%m-%d %H:%M")"

  # No active timesheet
  if [[ ! -f ~/.timeclock ]]; then
    echo "You are not clocked in."
    return
  fi

  last_line="$(tail -n 1 ~/.timeclock)"

  # Already clocked out
  if [[ "$last_line" == Clocked\ out\ at* ]]; then
    last_time="${last_line#Clocked out at }"
    echo "You are not clocked in. Your last clockout was at $last_time."
    return
  fi

  echo "Clocked out at $now"
  echo "Clocked out at $now" >> ~/.timeclock
}

# ----------------------------
# Close week (archive timesheet)
# ----------------------------
# Archives the current timesheet.
# If clocked in, prompts whether to clock out first.
#
# Options when prompted:
#   y → clock out, then archive
#   n → abort
#   s → skip clockout and archive anyway
# ----------------------------
clswk() {
  local last_line response archive_path

  if [[ ! -f ~/.timeclock ]]; then
    echo "There is no current timesheet to archive."
    return
  fi

  last_line="$(tail -n 1 ~/.timeclock)"

  # If currently clocked in
  if [[ "$last_line" == Clocked\ in\ at* ]]; then
    echo -n "You are clocked in. Clock out now? ('y'es, 'n'o, or 's'kip): "
    read response

    case "$response" in
      y|Y|yes|YES)
        clockout
        ;;
      n|N|no|NO)
        echo "Aborted."
        return
        ;;
      s|S|skip|SKIP)
        ;;
      *)
        echo "Invalid response. Aborted."
        return
        ;;
    esac
  fi

  mkdir -p ~/.timesheets
  archive_path="$HOME/.timesheets/TimeClock-$(date +%Y%m%d-%H%M%S).log"
  mv ~/.timeclock "$archive_path"

  echo "Timesheet archived to '$archive_path'."
}

# ----------------------------
# Timesheet comment
# ----------------------------
# Usage:
#   tscomm worked on API refactor
# ----------------------------
tscomm() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: tscomm <comment>"
    return 1
  fi

  # Ensure timesheet exists
  if [[ ! -f ~/.timeclock ]]; then
    touch ~/.timeclock
  fi

  echo "$*" >> ~/.timeclock
}

# ============================================================
# Development Tools
# ============================================================

# AWS profile switching
awsprofile() {
  export AWS_PROFILE="$1"
  echo "AWS_PROFILE is now set to '$AWS_PROFILE'"
}

# RepoMix (Docker-based)
alias repomix='docker run -v ${PWD}:/app -it --rm ghcr.io/yamadashy/repomix --style markdown'

# All Git Diffs on All Branches
alias diffs='git log --all --graph --patch --full-history'
`````

## File: CHANGELOG.md
`````markdown
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
`````

## File: README.md
`````markdown
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
`````

## File: VERSION.md
`````markdown
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
`````
