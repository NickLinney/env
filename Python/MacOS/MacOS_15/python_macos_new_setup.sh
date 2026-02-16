#!/usr/bin/env bash
# python_macos_new_setup.sh
#
# macOS Python baseline bootstrap (python.org installers)
#
# Installs multiple official CPython versions (3.9–3.13) via python.org universal2 .pkg installers,
# ensures they coexist under /Library/Frameworks/Python.framework/Versions/,
# and enforces Python 3.12 as the default via /usr/local/bin/python3 (+ pip3).
#
# Design goals:
# - Standards-aligned: python.org CPython + pip + venv
# - Minimal & auditable: no Poetry/uv/pipx; no dotfile writes
# - Idempotent: safe to rerun; skips already-installed versions
# - Integrity: verifies downloaded .pkg SHA256 by scraping python.org release pages

set -euo pipefail

# -----------------------------
# Config
# -----------------------------

# Target minor versions to ensure installed.
TARGET_MINORS=("3.9" "3.10" "3.11" "3.12" "3.13")

# Default interpreter minor version to enforce via /usr/local/bin symlinks.
DEFAULT_MINOR="3.12"

# Where python.org hosts release artifacts.
PY_FTP_ROOT="https://www.python.org/ftp/python"

# Where python.org hosts the release pages (for SHA256 extraction).
PY_RELEASE_PAGE_ROOT="https://www.python.org/downloads/release"

# Working dir (auto temp).
WORK_DIR=""

# -----------------------------
# Logging helpers
# -----------------------------

log()  { printf '%s\n' "[INFO] $*"; }
warn() { printf '%s\n' "[WARN] $*" >&2; }
die()  { printf '%s\n' "[ERROR] $*" >&2; exit 1; }

# -----------------------------
# Preconditions
# -----------------------------

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This script is intended for macOS (Darwin) only."
}

require_sudo() {
  # Prompt early so the run is smooth.
  if ! sudo -n true >/dev/null 2>&1; then
    log "Requesting sudo privileges (needed for installer + /usr/local/bin symlinks)..."
    sudo true || die "sudo authentication failed."
  fi
}

cleanup() {
  if [[ -n "${WORK_DIR}" && -d "${WORK_DIR}" ]]; then
    rm -rf "${WORK_DIR}" || true
  fi
}
trap cleanup EXIT

# -----------------------------
# Networking helpers
# -----------------------------

curl_get() {
  # shellcheck disable=SC2068
  curl -fsSL $@
}

# -----------------------------
# Python.org discovery helpers
# -----------------------------

minor_regex_escape() {
  # "3.12" -> "3\.12"
  local minor="$1"
  printf '%s' "${minor//./\\.}"
}

latest_patch_for_minor() {
  # Determine the latest patch version for a given minor by scraping the ftp listing.
  # Example: "3.12" -> "3.12.9" (depending on current latest).
  local minor="$1"
  local esc
  esc="$(minor_regex_escape "$minor")"

  # Fetch listing and extract all versions matching minor.patch (e.g. 3.12.0, 3.12.1 ...)
  # Then pick the greatest via sort -V.
  local listing versions latest
  listing="$(curl_get "${PY_FTP_ROOT}/")" || die "Failed to fetch python.org FTP listing."

  # Extract version strings that look like "3.12.N"
  # Note: grep -Eo returns one match per line.
  versions="$(printf '%s' "$listing" | grep -Eo "${esc}\.[0-9]+" | sort -Vu || true)"
  [[ -n "$versions" ]] || die "Could not determine latest patch for minor ${minor} from python.org FTP listing."

  latest="$(printf '%s\n' "$versions" | tail -n 1)"
  printf '%s' "$latest"
}

select_macos_pkg_filename() {
  # From a version directory listing, choose the most appropriate macOS .pkg.
  # Prefer macos11 (universal2 era) if present; otherwise choose any "python-${ver}-macos*.pkg".
  local version="$1"
  local dir_url="${PY_FTP_ROOT}/${version}/"
  local listing
  listing="$(curl_get "$dir_url")" || die "Failed to fetch python.org version directory listing: ${dir_url}"

  # Prefer macos11 (universal2 era). If multiple, take the first match.
  local preferred any
  preferred="$(printf '%s' "$listing" | grep -Eo "python-${version}-macos11\.pkg" | head -n 1 || true)"
  if [[ -n "$preferred" ]]; then
    printf '%s' "$preferred"
    return 0
  fi

  # Fallback: match any macos*.pkg (e.g. macos10.9.pkg in older minors)
  any="$(printf '%s' "$listing" | grep -Eo "python-${version}-macos[0-9.]+\.pkg" | head -n 1 || true)"
  [[ -n "$any" ]] || die "Could not find a macOS .pkg installer for Python ${version} in ${dir_url}"
  printf '%s' "$any"
}

release_slug_for_version() {
  # python.org release pages use a slug like:
  #   3.12.3 -> python-3123
  #   3.10.13 -> python-31013
  # i.e., remove dots.
  local version="$1"
  local nodots
  nodots="${version//./}"
  printf 'python-%s' "$nodots"
}

expected_sha256_for_filename() {
  # Scrape the python.org release page for a given version and filename,
  # then extract a 64-hex SHA256 string that appears near the filename.
  local version="$1"
  local filename="$2"

  local slug page_url page
  slug="$(release_slug_for_version "$version")"
  page_url="${PY_RELEASE_PAGE_ROOT}/${slug}/"

  page="$(curl_get "$page_url")" || die "Failed to fetch python.org release page: ${page_url}"

  # Heuristic:
  # - Find a chunk around the filename
  # - Extract the first 64-hex token nearby (the SHA256)
  #
  # This is intentionally simple and avoids external HTML parsers.
  local sha
  sha="$(
    printf '%s' "$page" \
      | tr '\n' ' ' \
      | sed -E 's/[[:space:]]+/ /g' \
      | grep -F -o "${filename}.{0,600}" \
      | head -n 1 \
      | grep -Eo '[a-f0-9]{64}' \
      | head -n 1 \
      || true
  )"

  [[ -n "$sha" ]] || die "Could not extract SHA256 for ${filename} from ${page_url}"
  printf '%s' "$sha"
}

# -----------------------------
# Installation helpers
# -----------------------------

framework_minor_bin_path() {
  # e.g. "3.12" -> "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3"
  local minor="$1"
  printf '/Library/Frameworks/Python.framework/Versions/%s/bin/python3' "$minor"
}

is_minor_installed() {
  local minor="$1"
  local py_path
  py_path="$(framework_minor_bin_path "$minor")"
  [[ -x "$py_path" ]]
}

download_pkg() {
  local version="$1"
  local filename="$2"
  local dest="$3"

  local url="${PY_FTP_ROOT}/${version}/${filename}"
  log "Downloading ${url}"
  curl -fL --retry 3 --retry-delay 2 -o "$dest" "$url" || die "Download failed: ${url}"
}

verify_sha256() {
  local pkg_path="$1"
  local expected="$2"

  local actual
  actual="$(shasum -a 256 "$pkg_path" | awk '{print $1}')" || die "Failed to compute SHA256: ${pkg_path}"

  if [[ "$actual" != "$expected" ]]; then
    die "SHA256 mismatch for $(basename "$pkg_path"): expected ${expected}, got ${actual}"
  fi
}

install_pkg() {
  local pkg_path="$1"
  log "Installing $(basename "$pkg_path") (requires sudo)..."
  sudo /usr/sbin/installer -pkg "$pkg_path" -target / >/dev/null || die "Installer failed: ${pkg_path}"
}

ensure_default_symlinks() {
  local minor="$1"
  local target_py="/Library/Frameworks/Python.framework/Versions/${minor}/bin/python3"
  local target_pip="/Library/Frameworks/Python.framework/Versions/${minor}/bin/pip3"

  [[ -x "$target_py" ]] || die "Default Python target not found/executable: ${target_py}"

  # Ensure /usr/local/bin exists (should on most systems; create if missing).
  sudo mkdir -p /usr/local/bin

  log "Setting default interpreter symlinks in /usr/local/bin (python3 -> ${minor})"
  sudo ln -sf "$target_py" /usr/local/bin/python3

  # pip3 may or may not exist depending on installer/state; link if present.
  if [[ -x "$target_pip" ]]; then
    sudo ln -sf "$target_pip" /usr/local/bin/pip3
  else
    warn "pip3 not found at expected path (${target_pip}); skipping pip3 symlink."
  fi
}

print_summary() {
  log "Installed Python framework versions detected:"
  for minor in "${TARGET_MINORS[@]}"; do
    if is_minor_installed "$minor"; then
      printf '%s\n' "  - ${minor}: present"
    else
      printf '%s\n' "  - ${minor}: missing"
    fi
  done

  printf '\n'
  log "Default resolution:"
  if command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "  which python3: $(command -v python3)"
    printf '%s\n' "  python3 --version: $(python3 --version 2>/dev/null || true)"
  else
    warn "python3 not found on PATH."
  fi

  # Also show explicit 3.12 if available
  local explicit="/Library/Frameworks/Python.framework/Versions/${DEFAULT_MINOR}/bin/python3"
  if [[ -x "$explicit" ]]; then
    printf '%s\n' "  explicit ${DEFAULT_MINOR}: $("$explicit" --version 2>/dev/null || true)"
  fi
}

# -----------------------------
# Main
# -----------------------------

main() {
  require_macos
  require_cmd curl
  require_cmd shasum
  require_cmd awk
  require_cmd sed
  require_cmd grep
  require_cmd sort
  require_cmd head
  require_cmd tail
  require_sudo

  WORK_DIR="$(mktemp -d -t python_macos_setup.XXXXXX)"
  log "Working directory: ${WORK_DIR}"

  # Install each target minor (latest patch for that minor).
  for minor in "${TARGET_MINORS[@]}"; do
    if is_minor_installed "$minor"; then
      log "Python ${minor} already installed; skipping."
      continue
    fi

    log "Resolving latest patch for Python ${minor} from python.org..."
    local version
    version="$(latest_patch_for_minor "$minor")"
    log "Latest patch for ${minor} is ${version}"

    local pkg_filename
    pkg_filename="$(select_macos_pkg_filename "$version")"
    log "Selected installer: ${pkg_filename}"

    local pkg_path="${WORK_DIR}/${pkg_filename}"

    download_pkg "$version" "$pkg_filename" "$pkg_path"

    log "Fetching expected SHA256 from python.org release page..."
    local expected_sha
    expected_sha="$(expected_sha256_for_filename "$version" "$pkg_filename")"
    log "Verifying SHA256..."
    verify_sha256 "$pkg_path" "$expected_sha"
    log "SHA256 verified."

    install_pkg "$pkg_path"

    # Post-install sanity check
    if is_minor_installed "$minor"; then
      log "Python ${minor} installed successfully."
    else
      die "Python ${minor} still not detected after install."
    fi
  done

  # Enforce default python3 -> 3.12 via /usr/local/bin symlink(s)
  ensure_default_symlinks "$DEFAULT_MINOR"

  # Final acceptance checks
  if ! is_minor_installed "$DEFAULT_MINOR"; then
    die "Default minor ${DEFAULT_MINOR} is not installed; cannot enforce default."
  fi

  # Verify python3 resolves to default minor
  local resolved
  resolved="$(python3 --version 2>/dev/null || true)"
  if [[ "$resolved" != "Python ${DEFAULT_MINOR}"* ]]; then
    warn "python3 does not report ${DEFAULT_MINOR}.x (got: ${resolved})."
    warn "This may indicate PATH precedence issues. Ensure /usr/local/bin is before other Python locations."
  fi

  print_summary
  log "Done."
}

main "$@"
