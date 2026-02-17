# VERSION.md

## Version
v0.5.0

## Release Date
2026-02-17

## Status
Personal environment templates repository.

Semantic Versioning (SemVer) is used to create stable, referenceable release points for repeatable machine bootstraps and consistent repository conventions.

---

## What This Version Represents

`v0.5.0` introduces a Debian Trixie–scoped, fully local AI coding assistant workflow for the Micro editor.

This release expands the repository beyond interpreter bootstraps and shell configuration by adding an editor-integrated module that remains:

- Local-first (no cloud dependency required)
- Conservative and auditable
- Modular (interactive vs provisioning modes)
- Designed for repeatable use in both workstation and container contexts

The repository continues to serve as a collection of environment templates, scripts, and conventions — not as a monolithic toolchain.

---

## Included In v0.5.0

### Added — Debian Trixie Micro Local LLM Assistant (Micro + Ollama + llm)

New module:

```

micro/Debian/trixie/

```

#### Interactive Setup Script

`micro-local-llm-setup.sh`

- Operator-driven install flow
- Installs:
  - Micro editor
  - Ollama
  - `llm` CLI + `llm-ollama`
  - `llm-micro` plugin
- Configures Micro keybindings (Alt-a, Alt-c)
- Optionally pulls a lightweight default model
- Designed for human-driven workstation setup

---

#### Non-Interactive Provisioning Script

`micro-local-llm-noninteractive.sh`

- Designed for Docker builds and CI pipelines
- Requires root (no sudo usage inside script)
- Targets a non-root user home via `--target-user` (default: `user`)
- Provides deterministic exit behavior:
  - Non-zero exit when errors occur
  - Exit code reflects accumulated error count (capped at 255)
- Supports:
  - `--skip-model-pull`
  - `--ollama-start-mode auto|background|never`

This enables reproducible, container-friendly provisioning while maintaining strict error signaling.

---

#### Documentation

- `micro/Debian/trixie/README.md`
  - Usage
  - Flags
  - Docker example
  - Remote execution examples
- `micro/Debian/trixie/AUTOMATION.md`
  - Provisioning design rationale
  - Operational notes
  - Tradeoffs and constraints

---

## Compatibility / Expectations

### Debian Trixie Scope

- Module is scoped to Debian Trixie by default.
- Designed for Debian-based environments.

### Model Pulling

- Models are pulled by tag (not digest-pinned).
- Tags may change over time.
- For deterministic image builds, use `--skip-model-pull` and manage models separately.

---

## Operational Notes

- This repository stores templates and bootstrap scripts — not machine state.
- No secrets should ever be committed.
- `.env` files are blocked by default; templates/examples are allowed.
- Scripts are written to be explicit, auditable, and conservative in behavior.

---

## Previous Versions

- v0.4.0 — Cross-platform Python default setup alignment
- v0.3.0 — Repository structure normalization and documentation cleanup
- v0.2.0 — Initial environment automation baseline