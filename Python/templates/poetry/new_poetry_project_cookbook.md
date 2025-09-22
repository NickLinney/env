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
