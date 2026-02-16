<# 
Bootstrap Windows Python environment (multi-version) + pipx (ADR-aligned baseline)
- Installs selected CPython versions via winget (python.org builds)
- Creates a per-user py.ini to set default `py` launcher version
- Installs pipx (user-local), ensures PATH, and pins default interpreter
- Optional: install additional CLI tools via pipx (empty by default; baseline installs none)

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
$GlobalTools       = @()                  # ADR baseline: empty by default (add 'ruff','black', etc. if desired)

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

  $iniDir = $env:LOCALAPPDATA
  if (-not (Test-Path $iniDir)) {
    New-Item -ItemType Directory -Force -Path $iniDir | Out-Null
  }

  $pyIni = Join-Path $iniDir 'py.ini'
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

  Write-Host "[*] Installing/Upgrading pip & pipx for Python $MinorVersion..."
  & py -$MinorVersion -m pip install --user -U pip pipx | Out-Host

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
foreach ($v in $PythonVersions) {
  Install-PythonVersion -MinorVersion $v
}

Write-Host "`n=== Discovered interpreters (py -0p) ==="
try {
  & py -0p | Out-Host
} catch {
  Write-Warning "The 'py' launcher is not on PATH yet. Open a new shell if needed."
}

Set-PyDefault -MinorVersion $DefaultPythonMinor
Ensure-Pipx -MinorVersion $DefaultPythonMinor

if ($InstallGlobalTools -and $GlobalTools.Count -gt 0) {
  Write-Host "`n=== Installing global CLI tools via pipx ==="
  Install-GlobalTools -Tools $GlobalTools
} else {
  Write-Host "`n=== Global CLI tools via pipx ==="
  Write-Host "[OK] None configured."
}

Write-Host "`n=== Final checks ==="
Write-Host "pipx version:"
try { & pipx --version | Out-Host } catch { Write-Warning "pipx not found on current PATH. Open a new PowerShell window." }

Write-Host "`nDetailed pipx state:"
try { & pipx list --verbose | Out-Host } catch { Write-Warning "pipx list failed; ensure a new shell after ensurepath." }

Write-Host "`nPython default (py):"
try { & py -V | Out-Host } catch { Write-Warning "py not found; ensure Python's launcher is on PATH or reopen shell." }

Write-Host "`nDone. If commands are missing, open a new PowerShell window to reload PATH."
