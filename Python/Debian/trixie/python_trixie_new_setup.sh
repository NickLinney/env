# ============================================================
# File: Python/Debian/trixie/python_trixie_new_setup.sh
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