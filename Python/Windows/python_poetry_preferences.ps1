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
