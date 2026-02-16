# =====================================================================
# File: Python/Windows/python_poetry_preferences.ps1
# Purpose:
#   - Ensure pipx and Poetry exist (Poetry installed via pipx if missing)
#   - Configure Poetry to use per-project ".venv"
#   - Pin Poetry to Python 3.12 (POETRY_PYTHON) and set py launcher default (PY_PYTHON=3.12)
#   - Upgrade base pip/setuptools/wheel on Python 3.12
#
# Notes:
#   - This is intentionally a "preferences" layer, not the canonical baseline.
#   - Run AFTER python_windows_new_setup.ps1.
#   - Open a NEW PowerShell session after running to pick up user env var changes.
# =====================================================================

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

function Step($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Info($m){ Write-Host "   $m" -ForegroundColor Gray }
function Warn($m){ Write-Host "   $m" -ForegroundColor Yellow }
function Die($m){ Write-Error $m; exit 1 }

# 0) Verify 'py' and locate Python 3.12
Step "Checking 'py' launcher and Python 3.12..."
if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
  Die "'py' launcher not found. Run python_windows_new_setup.ps1 first (or install Python) and re-run."
}

$py312Path = $null
try { $py312Path = (& py -3.12 -c "import sys; print(sys.executable)") } catch {}
if (-not $py312Path) {
  Die "Python 3.12 not found by 'py'. Install 3.12 (e.g., winget install --id Python.Python.3.12 -e) and re-run."
}
Info "Python 3.12 at: $py312Path"

# 1) Ensure pipx is present (user install)
Step "Ensuring pipx is installed..."
if (-not (Get-Command pipx -ErrorAction SilentlyContinue)) {
  Info "pipx not found; installing via Python 3.12 user site..."
  & py -3.12 -m pip install --user --upgrade pip | Out-Host
  & py -3.12 -m pip install --user --upgrade pipx | Out-Host

  try { & py -3.12 -m pipx ensurepath | Out-Null } catch { Warn "pipx ensurepath will take effect in a new shell." }

  # Make pipx available in this session (best-effort)
  $pipxBin = Join-Path $env:LocalAppData 'pipx\bin'
  if (Test-Path $pipxBin) {
    if (-not ($env:Path -split ';' | Where-Object { $_ -eq $pipxBin })) {
      $env:Path = "$pipxBin;$env:Path"
    }
  } else {
    # Fallback: user-base Scripts path (older pipx layouts)
    $userBase = (& py -3.12 -m site --user-base).Trim()
    $userScripts = Join-Path $userBase "Scripts"
    if (Test-Path $userScripts) {
      if (-not ($env:Path -split ';' | Where-Object { $_ -eq $userScripts })) {
        $env:Path = "$userScripts;$env:Path"
      }
    }
  }
}

try {
  $pipxVer = (pipx --version) 2>$null
  Info "pipx version: $pipxVer"
} catch {
  Warn "pipx is installed but not available on PATH in this session. Open a new PowerShell session after this script."
}

# (Optional) Ensure pipx uses Python 3.12 by default for new installs (preferences-level)
try {
  [Environment]::SetEnvironmentVariable('PIPX_DEFAULT_PYTHON', $py312Path, 'User')
  $env:PIPX_DEFAULT_PYTHON = $py312Path
  Info "Set PIPX_DEFAULT_PYTHON (User) to: $py312Path"
} catch {
  Warn "Unable to set PIPX_DEFAULT_PYTHON. This is non-fatal."
}

# 2) Ensure Poetry via pipx
Step "Ensuring Poetry is installed via pipx..."
$poetryOk = $false
try { $null = poetry --version 2>$null; $poetryOk = $true } catch {}
if (-not $poetryOk) {
  Info "Installing Poetry..."
  try {
    pipx install poetry | Out-Host
  } catch {
    # If Poetry is already present but broken, --force can repair
    Warn "pipx install poetry failed; attempting reinstall with --force..."
    pipx install poetry --force | Out-Host
  }
}

try {
  $poetryVer = (poetry --version) 2>$null
  Info "Poetry version: $poetryVer"
} catch {
  Die "Poetry is not available after installation. Open a new PowerShell session and re-run, or check pipx path."
}

# 3) Configure Poetry defaults (per-project .venv)
Step "Configuring Poetry defaults (per-project .venv)..."
poetry config virtualenvs.in-project true | Out-Null
Info "Set: poetry config virtualenvs.in-project true"

# 4) Pin interpreter defaults and upgrade base pip
Step "Setting user environment variables: POETRY_PYTHON and PY_PYTHON=3.12..."
setx POETRY_PYTHON "$py312Path" | Out-Null
setx PY_PYTHON "3.12" | Out-Null
Info "User env vars set. Open a NEW shell for them to take effect."

Step "Upgrading base pip/setuptools/wheel on Python 3.12..."
& py -3.12 -m pip install --upgrade pip setuptools wheel | Out-Host

Write-Host ""
Step "Done."
Write-Host "Poetry will default to Python 3.12 at: $py312Path" -ForegroundColor Green
Write-Host "Open a NEW PowerShell session to pick up POETRY_PYTHON and PY_PYTHON." -ForegroundColor Yellow
Write-Host "Per-project: 'poetry install' will create ./.venv (due to your global setting)." -ForegroundColor Gray
