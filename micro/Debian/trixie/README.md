# Local LLM Assistant for Micro Editor (Debian Trixie)

This feature provides a **fully local, private, and FOSS** AI coding assistant for the [Micro text editor](https://micro-editor.github.io/). It is optimized for **Debian Trixie (Testing)** and designed primarily for Dockerized deployments, while remaining compatible with both **AMD64** and **ARM64** architectures.

---

## 🚀 Quickstart

Run the following command to download and execute the setup script. The script will prompt before installing major components.

```bash
curl -fsSL https://raw.githubusercontent.com/NickLinney/env/main/micro/Debian/trixie/micro-local-llm-setup.sh | bash
````

---

## 🛠️ Features

* **Sovereign AI:** No subscriptions, no telemetry, and no external API calls required after the initial model pull.
* **Architecture Compatible:** Works on both AMD64 and ARM64 without architecture-specific branching.
* **Docker & Baremetal Compatible:** Detects absence of `systemd` and launches `ollama serve` in the background when necessary.
* **Debian-Compliant:** Defaults to `pipx` for Python CLI tools, respecting PEP 668 “externally managed” environments.
* **Distribution Guard:** Warns when the distribution name does not contain `trixie`.

---

## 📦 Components Installed

1. **[Micro Editor](https://micro-editor.github.io/)**
   A lightweight terminal-based editor with intuitive keybindings.

2. **[Ollama](https://ollama.com/)**
   Installed via the official upstream installer script.

3. **[LLM CLI](https://llm.datasette.io/)**
   Installed using `pipx` by default, with optional direct install for advanced users.

4. **llm-micro Plugin**
   Integrated into Micro for direct AI interaction.

5. **Llama 3.2 (1B)**
   Pulled by tag (`llama3.2:1b`) as a lightweight default model.
   *Not digest-pinned.*

---

## ⌨️ How to Use

After installation:

```bash
source ~/.bashrc
micro yourfile.py
```

Use the following keybindings inside Micro:

| Keybinding | Action         | Description                                                   |
| ---------- | -------------- | ------------------------------------------------------------- |
| **Alt-a**  | Ask / Refactor | Opens prompt at bottom. Generates or refactors selected text. |
| **Alt-c**  | Chat           | Opens vertical split chat session without modifying file.     |

If `llm` is not immediately available:

```bash
source ~/.bashrc
```

---

## 🐳 Docker / Non-Systemd Environments

If running inside a container or environment without `systemd`, ensure the Ollama server is active:

```bash
ollama serve &
```

The setup script automatically attempts to launch `ollama serve` in the background when `systemd` is not detected. It does **not** create or enable persistent services.

---

## ⚠️ Shell Behavior

The script appends the following to `.bashrc` if not already present:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

* Bash-targeted only.
* Does not modify `.zshrc`.
* zsh or alternative shell users must manually ensure `~/.local/bin` is in their PATH.

---

## ⚠️ Model Reproducibility & Performance Notes

* Model is pulled by tag (`llama3.2:1b`).
* No digest pinning is performed.
* No automatic memory or hardware validation is enforced.
* Users may manually change the default model after installation.

This design favors simplicity and minimal surface area for v0.5.0.

---

## 🔐 Security & Compliance Notes

* No system-level Python packages are modified.
* No global `pip` installs occur unless explicitly selected.
* No cloud LLM providers are configured.
* No telemetry or external inference services are used.

---

## 📁 Location Within Repository

```
env/
└─ micro/
   └─ Debian/
      └─ trixie/
         ├─ README.md
         └─ micro-local-llm-setup.sh
```

This structure maintains:

* OS-scoped organization
* Clean modular separation from Python bootstrap scripts
* Optional, opt-in tooling philosophy