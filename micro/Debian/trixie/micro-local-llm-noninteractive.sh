#!/bin/bash

# micro-local-llm-noninteractive.sh
# Non-interactive, CI/CD + Docker-friendly setup for Micro + local LLM (Ollama + llm + llm-micro)
#
# Key properties:
# - Root required (script performs apt installs and Ollama install)
# - Targets a non-root user home by default (DEFAULT_USER="user"), override with --target-user
# - Defaults to installing everything unless explicitly skipped
# - Tag-based model pulls (not digest-pinned)
# - Colors OFF by default for clean pipeline logs
# - Errors are logged; by default script exits non-zero if any errors occurred

set -uo pipefail

# ----------------------------
# Defaults (Operator-Tunable)
# ----------------------------

DEFAULT_USER="user"
TARGET_USER="${DEFAULT_USER}"

# Default model (tag-based)
MICRO_LLM_MODEL="${MICRO_LLM_MODEL:-llama3.2:1b}"
# Alternate curated model tags (uncomment to change default):
# MICRO_LLM_MODEL="qwen2.5-coder:1.5b"
# MICRO_LLM_MODEL="gemma2:2b"
# MICRO_LLM_MODEL="llama3.2:3b"
# MICRO_LLM_MODEL="gemma2:2b-instruct-q8_0"

ALLOW_NON_TRIXIE=false
BEST_EFFORT=false

SKIP_MICRO=false
SKIP_OLLAMA=false
SKIP_LLM=false
SKIP_PLUGIN=false
SKIP_MODEL_PULL=false

PYTHON_INSTALL_METHOD="pipx"       # pipx | break-system
OLLAMA_START_MODE="auto"           # auto | never | background
FORCE_PLUGIN_UPDATE=false
NO_BASHRC=false

# Hardcoded external upstream installer
OLLAMA_INSTALL_URL="https://ollama.com/install.sh"

# ----------------------------
# Logging (no colors by default)
# ----------------------------

log_info()  { echo "[INFO]  $*"; }
log_ok()    { echo "[OK]    $*"; }
log_warn()  { echo "[WARN]  $*"; }
log_error() { echo "[ERROR] $*"; }

ERROR_COUNT=0
WARN_COUNT=0
ABORTED=false
CURRENT_STEP="init"

fail_step() {
  local msg="$1"
  ERROR_COUNT=$((ERROR_COUNT + 1))
  log_error "Step '${CURRENT_STEP}' failed: ${msg}"
  if [[ "${BEST_EFFORT}" == "true" ]]; then
    return 0
  fi
  ABORTED=true
  return 0
}

warn_step() {
  WARN_COUNT=$((WARN_COUNT + 1))
  log_warn "$*"
}

should_continue() {
  [[ "${ABORTED}" != "true" ]]
}

# Run a command safely (never exits script; records error and aborts/continues per BEST_EFFORT)
run_cmd() {
  local desc="$1"
  shift
  if ! should_continue; then return 0; fi
  if "$@"; then
    log_ok "${desc}"
  else
    fail_step "${desc}"
  fi
}

# Run a command as TARGET_USER (via login shell). Uses TARGET_HOME for HOME-sensitive tools.
run_as_user() {
  local desc="$1"
  shift
  if ! should_continue; then return 0; fi
  if su - "${TARGET_USER}" -s /bin/bash -c "$*"; then
    log_ok "${desc}"
  else
    fail_step "${desc}"
  fi
}

# ----------------------------
# Arg Parsing
# ----------------------------

print_help() {
  cat <<'EOF'
micro-local-llm-noninteractive.sh

Non-interactive provisioning for Micro + Ollama + llm + llm-micro on Debian Trixie (Docker-friendly).
Root required. By default exits non-zero if any errors occurred.

Flags:
  --target-user <name>         Target user for plugin, llm config, .bashrc, etc. (default: user)
  --model <tag>                Override MICRO_LLM_MODEL (e.g., llama3.2:1b)
  --allow-non-trixie           Continue even if /etc/os-release does not contain 'trixie'
  --best-effort                Continue after errors (otherwise stop on first failure)
  --skip-micro                 Skip Micro installation
  --skip-ollama                Skip Ollama installation
  --skip-llm                   Skip llm + llm-ollama installation
  --skip-plugin                Skip llm-micro plugin install/config
  --skip-model-pull            Skip model pull + default model set
  --python-install-method <m>  pipx | break-system   (default: pipx)
  --ollama-start-mode <m>      auto | never | background (default: auto)
  --force-plugin-update        If plugin exists: git pull (if git repo) or replace directory (if not)
  --no-bashrc                  Do not modify target user's ~/.bashrc PATH export
  --help                       Show this help

Environment:
  MICRO_LLM_MODEL=<tag>        Default model tag (tag-based pull; may change over time)

Notes:
  - Model pulls are tag-based, not digest-pinned.
  - Target-user state (pipx, llm config, plugin, bindings, .bashrc) is written to that user's HOME.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-user)
      TARGET_USER="${2:-}"
      shift 2
      ;;
    --model)
      MICRO_LLM_MODEL="${2:-}"
      shift 2
      ;;
    --allow-non-trixie)
      ALLOW_NON_TRIXIE=true
      shift
      ;;
    --best-effort)
      BEST_EFFORT=true
      shift
      ;;
    --skip-micro)
      SKIP_MICRO=true
      shift
      ;;
    --skip-ollama)
      SKIP_OLLAMA=true
      shift
      ;;
    --skip-llm)
      SKIP_LLM=true
      shift
      ;;
    --skip-plugin)
      SKIP_PLUGIN=true
      shift
      ;;
    --skip-model-pull)
      SKIP_MODEL_PULL=true
      shift
      ;;
    --python-install-method)
      PYTHON_INSTALL_METHOD="${2:-}"
      shift 2
      ;;
    --ollama-start-mode)
      OLLAMA_START_MODE="${2:-}"
      shift 2
      ;;
    --force-plugin-update)
      FORCE_PLUGIN_UPDATE=true
      shift
      ;;
    --no-bashrc)
      NO_BASHRC=true
      shift
      ;;
    --help|-h)
      print_help
      exit 0
      ;;
    *)
      warn_step "Unknown argument: $1"
      shift
      ;;
  esac
done

# Validate enum-like args
case "${PYTHON_INSTALL_METHOD}" in
  pipx|break-system) ;;
  *)
    warn_step "Invalid --python-install-method '${PYTHON_INSTALL_METHOD}'. Falling back to 'pipx'."
    PYTHON_INSTALL_METHOD="pipx"
    ;;
esac

case "${OLLAMA_START_MODE}" in
  auto|never|background) ;;
  *)
    warn_step "Invalid --ollama-start-mode '${OLLAMA_START_MODE}'. Falling back to 'auto'."
    OLLAMA_START_MODE="auto"
    ;;
esac

# ----------------------------
# Preconditions
# ----------------------------

log_info "=== Debian Trixie Micro Local LLM Setup (non-interactive) ==="

CURRENT_STEP="preflight_root"
if [[ "$(id -u)" -ne 0 ]]; then
  log_error "Must run as root (this script intentionally avoids sudo)."
  exit 1
fi
log_ok "Running as root."

CURRENT_STEP="preflight_os"
if [[ ! -f /etc/os-release ]]; then
  log_error "/etc/os-release not found; cannot validate distribution."
  exit 1
fi

if ! grep -qi "trixie" /etc/os-release; then
  if [[ "${ALLOW_NON_TRIXIE}" == "true" ]]; then
    warn_step "Distribution name does not contain 'trixie' (continuing due to --allow-non-trixie)."
  else
    log_error "Distribution name does not contain 'trixie'. Refusing to proceed without --allow-non-trixie."
    exit 1
  fi
else
  log_ok "Detected 'trixie' in /etc/os-release."
fi

CURRENT_STEP="preflight_target_user"
if [[ -z "${TARGET_USER}" ]]; then
  log_error "--target-user was provided without a value."
  exit 1
fi

# Resolve TARGET_HOME
TARGET_HOME="$(getent passwd "${TARGET_USER}" | awk -F: '{print $6}' || true)"
if [[ -z "${TARGET_HOME}" ]] || [[ ! -d "${TARGET_HOME}" ]]; then
  log_error "Target user '${TARGET_USER}' does not exist or has no valid home directory."
  log_error "Resolved home: '${TARGET_HOME}'"
  exit 1
fi
log_ok "Target user: ${TARGET_USER} (HOME=${TARGET_HOME})"

CURRENT_STEP="preflight_arch"
ARCH="$(uname -m || true)"
log_info "Architecture: ${ARCH}"

# Track whether Micro existed for the target user before we touched anything (bindings backup semantics)
MICRO_PREEXISTING=false
if command -v micro >/dev/null 2>&1; then
  MICRO_PREEXISTING=true
fi

# ----------------------------
# Apt Dependencies
# ----------------------------

CURRENT_STEP="apt_update"
run_cmd "apt-get update" apt-get update -y

CURRENT_STEP="apt_install_deps"
run_cmd "apt-get install base dependencies" apt-get install -y \
  curl git python3-pip python3-venv pipx zstd procps xclip

# ----------------------------
# Install Micro
# ----------------------------

if [[ "${SKIP_MICRO}" == "true" ]]; then
  CURRENT_STEP="micro_skip"
  log_ok "Micro installation skipped (--skip-micro)."
else
  CURRENT_STEP="micro_install"
  if command -v micro >/dev/null 2>&1; then
    log_ok "Micro already installed, skipping."
  else
    run_cmd "Install Micro via apt-get" apt-get install -y micro
  fi
fi

# ----------------------------
# Install Ollama
# ----------------------------

if [[ "${SKIP_OLLAMA}" == "true" ]]; then
  CURRENT_STEP="ollama_skip"
  log_ok "Ollama installation skipped (--skip-ollama)."
else
  CURRENT_STEP="ollama_install"
  if command -v ollama >/dev/null 2>&1; then
    log_ok "Ollama already installed, skipping."
  else
    run_cmd "Install Ollama via upstream installer (${OLLAMA_INSTALL_URL})" bash -c "curl -fsSL '${OLLAMA_INSTALL_URL}' | sh"
  fi
fi

# ----------------------------
# Install llm CLI (+ llm-ollama) for TARGET_USER
# ----------------------------

if [[ "${SKIP_LLM}" == "true" ]]; then
  CURRENT_STEP="llm_skip"
  log_ok "llm installation skipped (--skip-llm)."
else
  CURRENT_STEP="llm_install"
  # Check llm in target user's PATH by running as user
  if su - "${TARGET_USER}" -s /bin/bash -c "command -v llm >/dev/null 2>&1"; then
    log_ok "llm already installed for ${TARGET_USER}, skipping."
  else
    if [[ "${PYTHON_INSTALL_METHOD}" == "break-system" ]]; then
      warn_step "Using --break-system-packages path (riskier on Debian/PEP 668 environments)."
      run_as_user "Install llm + llm-ollama via pip (--break-system-packages)" \
        "pip install llm llm-ollama --break-system-packages"
    else
      run_as_user "Install llm via pipx" "pipx install llm"
      run_as_user "Inject llm-ollama into llm pipx venv" "pipx inject llm llm-ollama"
      # This may modify bashrc; harmless, but we still do our own PATH export below.
      run_as_user "Ensure pipx PATH (pipx ensurepath)" "pipx ensurepath || true"
    fi
  fi
fi

# ----------------------------
# Plugin install/update + bindings (TARGET_USER home)
# ----------------------------

PLUGIN_DIR="${TARGET_HOME}/.config/micro/plug/llm"
BINDINGS_FILE="${TARGET_HOME}/.config/micro/bindings.json"

if [[ "${SKIP_PLUGIN}" == "true" ]]; then
  CURRENT_STEP="plugin_skip"
  log_ok "Plugin installation skipped (--skip-plugin)."
else
  CURRENT_STEP="plugin_install_or_update"

  # Ensure base plug directory exists (as target user)
  run_as_user "Ensure Micro plugin base directory exists" "mkdir -p '${TARGET_HOME}/.config/micro/plug'"

  if [[ -d "${PLUGIN_DIR}" ]]; then
    if [[ "${FORCE_PLUGIN_UPDATE}" == "true" ]]; then
      if [[ -d "${PLUGIN_DIR}/.git" ]]; then
        run_as_user "Update llm-micro plugin via git pull (ff-only)" "cd '${PLUGIN_DIR}' && git pull --ff-only"
      else
        warn_step "Plugin directory exists but is not a git repo; replacing due to --force-plugin-update."
        run_as_user "Replace llm-micro plugin directory" "rm -rf '${PLUGIN_DIR}'"
        run_as_user "Clone llm-micro plugin" "git clone https://github.com/shamanicvocalarts/llm-micro '${PLUGIN_DIR}'"
      fi
    else
      log_ok "Plugin directory already exists, skipping (use --force-plugin-update to refresh)."
    fi
  else
    run_as_user "Clone llm-micro plugin" "git clone https://github.com/shamanicvocalarts/llm-micro '${PLUGIN_DIR}'"
  fi

  # Configure bindings (backup only if bindings existed before modification and Micro existed system-wide)
  CURRENT_STEP="bindings_patch"
  run_as_user "Ensure Micro config directory exists" "mkdir -p '${TARGET_HOME}/.config/micro'"

  if [[ "${MICRO_PREEXISTING}" == "true" ]] && [[ -f "${BINDINGS_FILE}" ]]; then
    TS="$(date +%Y%m%d_%H%M%S)"
    run_as_user "Backup existing bindings.json" "cp '${BINDINGS_FILE}' '${BINDINGS_FILE}.bak.${TS}'"
  fi

  if [[ ! -f "${BINDINGS_FILE}" ]]; then
    run_as_user "Create empty bindings.json" "echo '{}' > '${BINDINGS_FILE}'"
  fi

  # Patch JSON via python (overwrites Alt-a / Alt-c by design)
  run_as_user "Patch bindings.json (Alt-a, Alt-c)" "python3 - <<'PY'
import json, os
path = os.path.expanduser('${BINDINGS_FILE}')
try:
    with open(path, 'r') as f:
        data = json.load(f)
except Exception:
    data = {}
data.update({'Alt-a': 'command-edit:llm ', 'Alt-c': 'command-edit:chat '})
with open(path, 'w') as f:
    json.dump(data, f, indent=4)
PY"
fi

# ----------------------------
# Ollama service start helpers
# ----------------------------

ollama_is_running_any() {
  pgrep -x "ollama" >/dev/null 2>&1
}

ollama_is_running_for_user() {
  pgrep -u "${TARGET_USER}" -x "ollama" >/dev/null 2>&1
}

systemd_is_active() {
  command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1
}

ensure_ollama_running_for_pull() {
  if [[ "${SKIP_OLLAMA}" == "true" ]]; then
    fail_step "Cannot ensure Ollama is running because --skip-ollama was set."
    return 0
  fi
  if ! command -v ollama >/dev/null 2>&1; then
    fail_step "Ollama is not installed; cannot pull models."
    return 0
  fi

  # If already running (any user), accept it.
  if ollama_is_running_any; then
    log_ok "Ollama already running."
    return 0
  fi

  case "${OLLAMA_START_MODE}" in
    never)
      fail_step "Ollama not running and --ollama-start-mode=never; skipping model pull."
      return 0
      ;;
    background)
      log_info "Starting Ollama in background as ${TARGET_USER} (--ollama-start-mode=background)..."
      # nohup avoids dying on su session end; log file is disposable
      su - "${TARGET_USER}" -s /bin/bash -c "nohup ollama serve >/tmp/ollama-${TARGET_USER}.log 2>&1 &" || true
      sleep 5 || true
      if ollama_is_running_any; then
        log_ok "Ollama started in background."
      else
        fail_step "Failed to start Ollama in background."
      fi
      ;;
    auto)
      if systemd_is_active; then
        # More resilient than the earlier version: attempt to start service once.
        log_info "systemd appears active; attempting to start Ollama service..."
        if systemctl start ollama >/dev/null 2>&1; then
          log_ok "systemctl start ollama succeeded."
          sleep 3 || true
          if ollama_is_running_any; then
            log_ok "Ollama is running after systemctl start."
          else
            fail_step "Ollama still not running after systemctl start; skipping model pull."
          fi
        else
          fail_step "systemctl start ollama failed; skipping model pull."
        fi
        return 0
      fi
      log_info "Starting Ollama in background as ${TARGET_USER} (auto; non-systemd detected)..."
      su - "${TARGET_USER}" -s /bin/bash -c "nohup ollama serve >/tmp/ollama-${TARGET_USER}.log 2>&1 &" || true
      sleep 5 || true
      if ollama_is_running_any; then
        log_ok "Ollama started in background."
      else
        fail_step "Failed to start Ollama in background."
      fi
      ;;
  esac
}

model_is_present() {
  # Return 0 if model exists locally (as seen by 'ollama list' under TARGET_USER)
  local model="$1"
  if ! command -v ollama >/dev/null 2>&1; then
    return 1
  fi
  su - "${TARGET_USER}" -s /bin/bash -c "ollama list 2>/dev/null | tail -n +2 | awk '{print \$1}' | grep -Fxq '${model}'"
}

# ----------------------------
# Model pull + default model set (tag-based) for TARGET_USER
# ----------------------------

if [[ "${SKIP_MODEL_PULL}" == "true" ]]; then
  CURRENT_STEP="model_skip"
  log_ok "Model pull skipped (--skip-model-pull)."
else
  CURRENT_STEP="model_pull"
  log_info "Model (tag-based): ${MICRO_LLM_MODEL}"

  if ! should_continue; then
    log_warn "Skipping model pull because script is aborted due to earlier error."
  else
    ensure_ollama_running_for_pull

    if should_continue; then
      if model_is_present "${MICRO_LLM_MODEL}"; then
        log_ok "Model already present for ${TARGET_USER}, skipping pull: ${MICRO_LLM_MODEL}"
      else
        run_as_user "Pull model via ollama (tag-based): ${MICRO_LLM_MODEL}" "ollama pull '${MICRO_LLM_MODEL}'"
      fi

      # Set llm default model for target user (requires llm)
      if su - "${TARGET_USER}" -s /bin/bash -c "command -v llm >/dev/null 2>&1"; then
        run_as_user "Set default llm model: ${MICRO_LLM_MODEL}" "llm models default '${MICRO_LLM_MODEL}'"
      else
        fail_step "llm command not found for ${TARGET_USER}; cannot set default model."
      fi
    fi
  fi
fi

# ----------------------------
# Target user's .bashrc PATH persistence (default ON)
# ----------------------------

CURRENT_STEP="bashrc_update"
if [[ "${NO_BASHRC}" == "true" ]]; then
  log_ok ".bashrc update skipped (--no-bashrc)."
else
  TARGET_BASHRC="${TARGET_HOME}/.bashrc"
  if [[ -f "${TARGET_BASHRC}" ]]; then
    if grep -q '\.local/bin' "${TARGET_BASHRC}"; then
      log_ok "Target .bashrc already contains .local/bin PATH entry, skipping."
    else
      run_as_user "Append ~/.local/bin PATH export to target .bashrc" \
        "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '${TARGET_BASHRC}'"
    fi
  else
    # Create .bashrc if missing (common in minimal images), then append.
    run_as_user "Create target .bashrc" "touch '${TARGET_BASHRC}'"
    run_as_user "Append ~/.local/bin PATH export to target .bashrc" \
      "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '${TARGET_BASHRC}'"
  fi
fi

# ----------------------------
# Summary + Exit Code
# ----------------------------

echo ""
log_info "=== Summary ==="
log_info "Target user: ${TARGET_USER} (HOME=${TARGET_HOME})"
log_info "Allow non-trixie: ${ALLOW_NON_TRIXIE}"
log_info "Best effort: ${BEST_EFFORT}"
log_info "Python install method: ${PYTHON_INSTALL_METHOD}"
log_info "Ollama start mode: ${OLLAMA_START_MODE}"
log_info "Force plugin update: ${FORCE_PLUGIN_UPDATE}"
log_info "No bashrc: ${NO_BASHRC}"
log_info "Model: ${MICRO_LLM_MODEL}"
log_info "Skipped: micro=${SKIP_MICRO}, ollama=${SKIP_OLLAMA}, llm=${SKIP_LLM}, plugin=${SKIP_PLUGIN}, model_pull=${SKIP_MODEL_PULL}"
log_info "Warnings: ${WARN_COUNT}"
log_info "Errors: ${ERROR_COUNT}"

if [[ "${ERROR_COUNT}" -gt 0 ]]; then
  log_error "Completed with ${ERROR_COUNT} error(s)."
  # Exit non-zero if errors occurred (CI-friendly strictness).
  # Cap at 255 for shell compatibility.
  if [[ "${ERROR_COUNT}" -gt 255 ]]; then
    exit 255
  fi
  exit "${ERROR_COUNT}"
fi

log_ok "Completed successfully."
exit 0
