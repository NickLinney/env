# NickLinney/env

This repository contains scripts, templates, and guides for bootstrapping and managing consistent development environments across operating systems.  
It is primarily focused on **Windows** today, with future Linux/macOS additions planned.

---

## Repository Structure

```

Python/
Windows/          # Windows-specific PowerShell setup scripts
templates/        # Shared templates (gitignore, cookbooks, etc.)
LICENSE.md          # MIT License

````

- **Windows Setup** → [Python/Windows/README.md](Python/Windows/README.md)  
- **Poetry Project Cookbook** → [Python/templates/poetry/new_poetry_project_cookbook.md](Python/templates/poetry/new_poetry_project_cookbook.md)

---

## Purpose

- Speed up onboarding on new machines.  
- Provide consistent **Python + Poetry configuration** (multi-version, isolated venvs).  
- Ensure new projects follow a **common baseline**:
  - per-project `.venv/`
  - standardized `.gitignore`
  - clear dependency management practices

---

## Quick Start (Windows)

```powershell
cd ~/Documents/Workspace

git clone https://github.com/NickLinney/env.git

./env/Python/Windows/python_windows_new_setup.ps1
./env/Python/Windows/python_poetry_preferences.ps1
````

Then create your first Poetry project:

```powershell
cd ~/Documents/Workspace
poetry new myapp --src
cd myapp
copy ~/Documents/Workspace/env/Python/templates/gitignore/python-poetry.gitignore .\.gitignore

poetry env use 3.12
poetry install
poetry run python -V
```

---

## Example Layout After Setup

```text
Workspace/
├─ env/                      # this repository
│  ├─ Python/
│  │  ├─ Windows/            # setup scripts
│  │  └─ templates/          # .gitignore + cookbooks
│  └─ LICENSE.md
└─ myapp/                    # a new Poetry project
   ├─ .venv/                 # auto-created virtualenv
   ├─ .gitignore             # copied from templates
   ├─ pyproject.toml          # Poetry config + deps
   ├─ README.md
   ├─ src/                   # source code
   └─ tests/                 # pytest tests
```

---

## Roadmap

* [ ] Add **Linux setup scripts** (`bash`)
* [ ] Add **macOS setup scripts** (`zsh`)
* [ ] Introduce versioned tags for templates

---

## License

This project is licensed under the [MIT License](LICENSE.md).
