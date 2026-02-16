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
bash Python/Debian/trixie/python_trixie_new_setup.sh
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