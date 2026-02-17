# AUTOMATION.md — Non-Interactive Provisioning Notes (Micro + Local LLM)

This directory contains two setup scripts that serve different operational contexts:

- **Interactive operator setup:** `micro-local-llm-setup.sh`  
  Designed for human-driven installs with prompts and safe defaults.

- **Non-interactive provisioning setup:** `micro-local-llm-noninteractive.sh`  
  Designed for Dockerfiles, CI pipelines, and image build automation where **no prompts** are acceptable.

This document captures the design decisions, tradeoffs, and usage guidance for the non-interactive script.

---

## 1) Why a Separate Non-Interactive Script Exists

Interactive scripts optimize for:
- guided prompts
- operator choice at runtime
- safer onboarding with confirmations

Provisioning scripts optimize for:
- repeatability
- zero prompts / zero TTY assumptions
- idempotent runs
- predictable exit codes
- CI-readable logging

Attempting to merge both styles into a single script typically creates:
- flag clutter
- branching complexity
- brittle behavior in CI (where prompts and TTY checks fail)

**Decision:** Maintain a dedicated provisioning script with a clean non-interactive contract.

---

## 2) High-Level Behavior (Non-Interactive)

`micro-local-llm-noninteractive.sh` performs:

1. Validates it is running as `root`
2. Validates Debian Trixie (unless explicitly overridden)
3. Installs required system packages via `apt-get`
4. Installs Micro via `apt-get` (unless skipped)
5. Installs Ollama via official upstream installer (unless skipped)
6. Installs `llm` + `llm-ollama` for the **target user** (pipx by default)
7. Installs or updates the Micro plugin (`llm-micro`) in the target user’s config
8. Backs up and patches `bindings.json` for the target user
9. Optionally pulls an Ollama model and sets it as the default for `llm`
10. Ensures `~/.local/bin` is in the target user’s `.bashrc` (unless disabled)

---

## 3) Key Design Decisions

### 3.1 Root Required (No `sudo`)
Provisioning commonly runs in environments where:
- the process is already root (Docker build layers)
- `sudo` is unavailable or undesirable

**Decision:** Require root explicitly and fail early if not root.

This also ensures:
- `apt-get` always works without prompts
- system-level installs remain deterministic

---

### 3.2 Target User Support (`--target-user`)
Provisioning frequently needs to install system packages as root **but** write editor configs for a non-root user.

If the script ran as root and used `$HOME`, it would write config to `/root`, which is usually wrong for a turnkey desktop/VNC user environment.

**Decision:**
- Default target user: `user`
- Support override: `--target-user <name>`
- Resolve target home using `getent passwd`

All Micro plugin configuration, bindings, and `llm` configuration are applied within the **target user’s home directory**, not root’s.

---

### 3.3 Debian Trixie Gate
Debian Testing may not always express “trixie” identically across derivatives, but this feature is intentionally scoped and conservative.

**Decision:**
- Fail by default if `/etc/os-release` does not contain `trixie`
- Allow override with `--allow-non-trixie`

This prevents accidental use on unexpected distributions.

---

### 3.4 Tag-Based Model Pulls (Not Digest-Pinned)
Model pulls use tags (e.g., `llama3.2:1b`).

**Decision:** Keep tag-based pulls for simplicity.
- Pros: simplest pipeline; no extra registry plumbing
- Cons: tag content may change over time (not bit-for-bit reproducible)

Documentation explicitly states this tradeoff.

---

### 3.5 Exit Codes: Strict by Default
In strict CI pipelines, exit codes must reflect failure.

**Decision:** The script exits non-zero if `ERROR_COUNT > 0`.

- Exit code is `ERROR_COUNT` (capped at 255).
- Use `--best-effort` to continue after errors; exit code still reflects total errors.

This makes the script suitable for:
- strict pipelines (detect failures)
- best-effort image builds (complete as much as possible, but still report failure via exit code)

---

### 3.6 Service Management Strategy (Ollama)
In Docker builds, service startup is often undesirable. In runtime container sessions, it may be needed.

**Decision:** Support three explicit policies with `--ollama-start-mode`:

- `auto` (default)
  - If systemd is active: attempt `systemctl start ollama` once, then verify
  - If systemd is not active: start `ollama serve` in background as the target user

- `background`
  - Always attempt background start as target user

- `never`
  - Never start Ollama
  - If model pull requested and Ollama isn’t running, model pull is skipped and recorded as an error

This keeps behavior predictable and explicit.

---

### 3.7 Plugin Update Policy
Provisioning scripts need idempotence but should not clobber user changes unless explicitly requested.

**Decision:**
- If plugin exists: do nothing (default)
- If `--force-plugin-update`:
  - If plugin is a git repo: `git pull --ff-only`
  - If not a git repo: replace directory and re-clone

This balances safety and maintainability.

---

### 3.8 `.bashrc` Updates Default On
Even though the script targets CI/Docker provisioning, the primary use case is often a turnkey runtime environment (e.g., VNC session user shells).

**Decision:** Update target user’s `.bashrc` by default to include:

```bash
export PATH="$HOME/.local/bin:$PATH"
````

Disable via `--no-bashrc`.

---

## 4) Model Selection

The non-interactive script uses a single default variable:

```bash
MICRO_LLM_MODEL="llama3.2:1b"
```

The script includes commented alternate models that can be enabled by editing the script or by setting:

```bash
MICRO_LLM_MODEL="<tag>"
```

You may also override via:

```bash
--model "<tag>"
```

---

## 5) Usage Examples

### 5.1 Dockerfile Build (Strict)

Install everything and pull the default model:

```bash
bash micro-local-llm-noninteractive.sh
```

### 5.2 Dockerfile Build (Skip model pull)

Useful when building images without large artifacts:

```bash
bash micro-local-llm-noninteractive.sh --skip-model-pull
```

### 5.3 Use a Different Target User

If your container user is `coder`:

```bash
bash micro-local-llm-noninteractive.sh --target-user coder
```

### 5.4 Non-Trixie Override

For a derivative or customized image:

```bash
bash micro-local-llm-noninteractive.sh --allow-non-trixie
```

### 5.5 Best Effort Mode

Continue past errors, but still exit non-zero if failures occurred:

```bash
bash micro-local-llm-noninteractive.sh --best-effort
```

### 5.6 Avoid `.bashrc` changes

If you want to manage PATH elsewhere:

```bash
bash micro-local-llm-noninteractive.sh --no-bashrc
```

### 5.7 Disable service start

Install software but do not start background daemons:

```bash
bash micro-local-llm-noninteractive.sh --ollama-start-mode never --skip-model-pull
```

---

## 6) Operational Notes and Known Constraints

### Headless clipboard tools

`xclip` may be dormant in headless environments without X11. This is expected and not treated as a failure.

### `llm` config location

`llm` stores its configuration in the target user’s home directory (e.g., `~/.local/share/...`). This is intentional so the target user’s editor sessions have the correct defaults.

### Model storage size

Models are large artifacts. Consider `--skip-model-pull` during build and pulling at runtime if image size is a concern.

---

## 7) Troubleshooting

### Ollama not running

If model pull fails due to Ollama not running:

* set `--ollama-start-mode background`
* or start it manually:

  ```bash
  ollama serve &
  ```

### `llm` not found in shells

Ensure `~/.local/bin` is present in PATH:

* re-source `.bashrc`:

  ```bash
  source ~/.bashrc
  ```

### Exit Codes

The script exits with a non-zero code equal to the number of recorded errors (capped at 255).

---

## 8) Maintenance Guidance

When modifying the provisioning script:

* preserve non-interactive contract (no prompts, no TTY assumptions)
* keep steps idempotent
* keep logs CI-readable
* update this document when behavioral decisions change
* update README.md only for operator-facing “what it does,” and keep deeper logic here
