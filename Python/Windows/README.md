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
