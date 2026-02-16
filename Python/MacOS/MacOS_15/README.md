# macOS 15 — Python Default Setup

This directory contains a macOS 15–scoped bootstrap script for establishing a clean, repeatable Python development baseline using **official python.org installers**.

The script installs multiple CPython versions side-by-side and enforces a conservative default interpreter without introducing workflow tooling, lockfiles, or shell modifications.

---

## Purpose

The goal is to provide a:

- Standards-aligned Python installation
- Predictable `python3` default
- Fully idempotent system bootstrap
- Minimal, auditable behavior

This script installs multiple Python versions and configures the default interpreter explicitly, without modifying dotfiles or introducing package manager abstractions.

---

## Installed Versions

The script ensures the following CPython versions are present:

- 3.9 (latest patch)
- 3.10 (latest patch)
- 3.11 (latest patch)
- 3.12 (latest patch)
- 3.13 (latest patch)

All versions are installed under:

```
/Library/Frameworks/Python.framework/Versions/
```

Python **3.12** is enforced as the default `python3`.

---

## What This Script Does

- Downloads official python.org **universal2** installers
- Verifies SHA256 checksums against python.org release pages
- Installs missing versions
- Skips already-installed versions
- Sets:

```
/usr/local/bin/python3 -> Python 3.12
/usr/local/bin/pip3    -> Python 3.12 pip (if present)
````

- Prints a final summary of installed versions and active default

---

## What This Script Does Not Do

- Install Poetry, uv, pipx, or other tooling
- Install global Python packages
- Modify `.zshrc`, `.zprofile`, or other shell configuration
- Use Homebrew or pyenv
- Remove or overwrite existing Python framework versions

---

## Quickstart

Run directly from GitHub without cloning the repository:

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/Python/MacOS/MacOS_15/python_macos_new_setup.sh | bash
````

Notes:

* The script will request `sudo` for the installer and `/usr/local/bin` symlinks.
* If you prefer to review the script first, clone the repo and run locally (below).

---

## Local Clone Execution

```bash
git clone https://github.com/NickLinney/env.git
cd env
bash Python/MacOS/MacOS_15/python_macos_new_setup.sh
```

---

## Verifying Installation

Check default interpreter:

```bash
python3 --version
```

Expected:

```
Python 3.12.x
```

Check installed versions:

```bash
ls /Library/Frameworks/Python.framework/Versions/
```

Test explicit interpreter:

```bash
python3.13 --version
```

Test virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
python --version
```

---

## Changing the Default Interpreter

The default interpreter is controlled by symlinks in:

```
/usr/local/bin/
```

To switch default manually:

```bash
sudo ln -sf /Library/Frameworks/Python.framework/Versions/3.13/bin/python3 /usr/local/bin/python3
```

This change is local and will not be overwritten unless the setup script is re-run.

---

## Idempotency

The script is safe to run multiple times.

* Existing versions are detected and skipped.
* Symlinks are updated only if necessary.
* No destructive operations occur.

---

## Assumptions

* macOS 15 (Sequoia)
* Internet connectivity
* Ability to use `sudo`
* `/usr/local/bin` is present in PATH before other Python locations

If `python3` does not resolve to 3.12 after installation, check:

```bash
which python3
echo $PATH
```

Ensure `/usr/local/bin` appears before other Python paths.

---

## Intended Usage

This script establishes a clean, minimal baseline suitable for:

* Virtual environment–based development
* CI-aligned workflows
* Multi-version interpreter testing

All project dependencies should be installed inside explicit `venv` environments.
