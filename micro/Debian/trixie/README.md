# Local LLM Assistant for Micro Editor (Debian Trixie)

This directory provides a **fully local, private, FOSS-based AI coding assistant** for the [Micro text editor](https://micro-editor.github.io/) using:

- **Micro** (terminal editor)
- **Ollama** (local inference engine)
- **llm CLI** (model bridge and orchestration)
- **llm-micro plugin** (editor integration)

It is explicitly scoped and optimized for **Debian Trixie (Testing)** and is suitable for both:

- 🧑‍💻 Interactive developer setup
- 🤖 Docker / CI provisioning workflows

---

# Overview

Two scripts are provided:

| Script | Purpose | Intended Use |
|--------|----------|--------------|
| `micro-local-llm-setup.sh` | Interactive operator-driven setup | Local workstation installs |
| `micro-local-llm-noninteractive.sh` | Fully automated provisioning | Dockerfiles, CI/CD pipelines, image builds |

Both scripts:

- Install Micro via `apt`
- Install Ollama via official upstream installer
- Install `llm` CLI (default: `pipx`)
- Integrate `llm-micro`
- Configure keybindings
- Optionally pull a lightweight baseline model

The difference is strictly in **interaction model and operational guarantees**.

---

# 🧑‍💻 Interactive Setup (Human-Driven)

Use this when configuring a development machine directly.

### One-Line Remote Execution

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-setup.sh | bash
````

### Behavior

* Prompts before major steps
* Default safe installation choices
* Designed for individual operator use
* Installs and configures directly for the current user

### Model

By default:

```
llama3.2:1b
```

Tag-based pull (not digest-pinned).

---

# 🤖 CI/CD and Non-Interactive Use

For Dockerfile builds, automated provisioning, or CI pipelines, use the non-interactive version of the setup script. This script requires **root** privileges to perform system-level installations but targets a specific user for configuration.

---

## One-Line Remote Execution

This command executes the script with default settings:

* Target User: `user`
* Model: `llama3.2:1b`

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-noninteractive.sh | bash
```

---

## Dockerfile Integration Example

Use the following pattern to bake the local LLM environment into your images.

The script exits with a **non-zero code if any errors occur**, ensuring your build fails if a component is missing.

```dockerfile
# Example: Provisioning for a custom 'coder' user
RUN curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-noninteractive.sh -o setup.sh \
    && bash setup.sh --target-user coder --model gemma2:2b --skip-model-pull \
    && rm setup.sh
```

---

## Common Provisioning Flags

| Flag                      | Description                                                                      |
| ------------------------- | -------------------------------------------------------------------------------- |
| `--target-user <name>`    | Sets the user for plugin, `llm` config, and `.bashrc` updates (default: `user`). |
| `--model <tag>`           | Overrides the default LLM model tag.                                             |
| `--skip-model-pull`       | Installs the stack but skips the large model download to keep images small.      |
| `--ollama-start-mode <m>` | `background`, `never`, or `auto` (default). Controls service lifecycle.          |
| `--skip-plugin`           | Installs stack but skips Micro plugin setup.                                     |
| `--force-plugin-update`   | Attempts git pull or replaces plugin directory if not a git repo.                |
| `--best-effort`           | Continues execution after errors, but still exits non-zero if failures occurred. |
| `--allow-non-trixie`      | Allows installation on non-Trixie systems (not recommended).                     |
| `--no-bashrc`             | Prevents PATH modifications in target user's `.bashrc`.                          |

For full design rationale and deeper operational details, see `AUTOMATION.md`.

---

# 📦 Components Installed

1. **Micro**

   * Installed via `apt`
   * Lightweight, terminal-native editor

2. **Ollama**

   * Installed via official upstream installer
   * Runs models locally
   * Service start behavior controlled by flags

3. **llm CLI**

   * Installed via `pipx` (default)
   * PEP 668 compliant (Debian externally-managed environment safe)

4. **llm-micro Plugin**

   * Cloned into:

     ```
     ~/.config/micro/plug/llm
     ```
   * Adds:

     * `Alt-a` → `command-edit:llm`
     * `Alt-c` → `command-edit:chat`

5. **Baseline Model**

   * Default: `llama3.2:1b`
   * Pulled by tag (not digest-pinned)

---

# ⌨️ Using the Assistant in Micro

Open any file with:

```bash
micro filename.py
```

### Keybindings

| Keybinding | Action         | Description                                        |
| ---------- | -------------- | -------------------------------------------------- |
| `Alt-a`    | Ask / Refactor | Prompts AI to edit highlighted selection           |
| `Alt-c`    | Chat           | Opens vertical split for conversational assistance |

---

# 🧠 Model Behavior and Reproducibility

Models are pulled by tag, e.g.:

```
llama3.2:1b
```

This means:

* ✔ Simple and lightweight
* ✔ Easy upgrades
* ❗ Not digest-pinned (model bits may change over time)

If strict reproducibility is required:

* Pull models manually
* Pin by digest
* Or manage models outside this script

This project intentionally prioritizes simplicity for v0.5.0.

---

# 🐳 Docker and Service Behavior

Ollama service behavior is controlled via:

```
--ollama-start-mode auto|background|never
```

* `auto`:

  * Uses `systemctl start ollama` if systemd present
  * Otherwise runs `ollama serve` in background

* `background`:

  * Always start `ollama serve`

* `never`:

  * Do not start service (model pull will fail if not running)

For minimal images:

* Use `--skip-model-pull`
* Start Ollama at container runtime

---

# 🛡 Design Principles

This feature adheres to:

* **FOSS-first tooling**
* **No cloud dependencies**
* **Debian PEP 668 compliance**
* **Isolation via pipx**
* **Modular, opt-in architecture**
* **Clear separation between interactive and provisioning workflows**

It does not:

* Replace system Python
* Install global pip packages (unless explicitly requested)
* Force cloud model providers
* Digest-pin models
* Hard-code service orchestration policies

---

# 📁 Directory Layout

```
micro/
└── Debian/
    └── trixie/
        ├── README.md
        ├── AUTOMATION.md
        ├── micro-local-llm-setup.sh
        └── micro-local-llm-noninteractive.sh
```

---

# 🧭 Recommended Usage Pattern

| Use Case                           | Script                                                |
| ---------------------------------- | ----------------------------------------------------- |
| Personal Debian Trixie workstation | `micro-local-llm-setup.sh`                            |
| Dev container / VNC container      | `micro-local-llm-noninteractive.sh`                   |
| CI image build pipeline            | `micro-local-llm-noninteractive.sh`                   |
| Reproducible image bake            | `micro-local-llm-noninteractive.sh --skip-model-pull` |

* For deterministic infrastructure builds, consider managing models externally and using --skip-model-pull during image bake.

---

# 📝 Final Notes

This module provides AI-assisted development tooling while preserving:

* OS bootstrap isolation
* Python environment integrity
* Modular design boundaries
* Transparent operational behavior

For deeper implementation details and policy reasoning, refer to `AUTOMATION.md`.
