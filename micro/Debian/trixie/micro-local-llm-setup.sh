#!/bin/bash

# Fail fast on errors and undefined vars; safer automation defaults.
set -euo pipefail

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Debian Trixie Micro Local LLM Setup ===${NC}"

# Helper for prompts with defaults
ask_prompt() {
    local prompt=$1
    local default=$2
    local choice
    echo ""
    if [[ "$default" == "Y" ]]; then
        read -r -p "$(echo -e "${prompt} [${GREEN}Y${NC}/n]: ")" choice
        [[ -z "$choice" || "$choice" =~ ^[yY]$ ]] && return 0 || return 1
    else
        read -r -p "$(echo -e "${prompt} [y/${RED}N${NC}]: ")" choice
        [[ "$choice" =~ ^[yY]$ ]] && return 0 || return 1
    fi
}

# 1. Distro Check
if ! grep -qi "trixie" /etc/os-release; then
    echo -e "${YELLOW}Warning: Distribution name does not contain 'trixie'. This script is optimized for Debian Trixie.${NC}"
    if ! ask_prompt "Proceed anyway?" "N"; then exit 1; fi
fi

# 2. Architecture & Immediate Path Prep
ARCH=$(uname -m)
echo -e "System Architecture: ${YELLOW}$ARCH${NC}"
# This makes the rest of the script work without manual sourcing
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# Track whether Micro was already installed before we touch anything.
MICRO_PREEXISTING=false
if command -v micro &> /dev/null; then
    MICRO_PREEXISTING=true
fi

# 3. Dependency Installation (Apt)
echo -e "\n${GREEN}Installing system dependencies...${NC}"
sudo apt update
sudo apt install -y curl git python3-pip xclip python3-venv pipx zstd procps

# 4. Micro Text Editor
if ! command -v micro &> /dev/null; then
    if ask_prompt "Install Micro Text Editor?" "Y"; then
        sudo apt install -y micro
    fi
fi

# 5. Ollama Inference Engine
if ! command -v ollama &> /dev/null; then
    if ask_prompt "Install Ollama?" "Y"; then
        curl -fsSL https://ollama.com/install.sh | sh
        if ! command -v systemctl &> /dev/null || ! systemctl is-system-running &> /dev/null; then
            echo -e "${YELLOW}Starting Ollama in background...${NC}"
            ollama serve > /dev/null 2>&1 &
            sleep 5
        fi
    fi
fi

# 6. LLM CLI Installation
if ! command -v llm &> /dev/null; then
    echo -e "\n${YELLOW}Python Environment Choice:${NC}"
    echo "1) [Recommended] pipx (Isolated, safe for Debian)"
    echo "2) --break-system-packages (Direct, risky)"
    read -r -p "Select [1/2] (Default 1): " py_choice

    if [[ "$py_choice" == "2" ]]; then
        pip install llm llm-ollama --break-system-packages
    else
        pipx install llm
        pipx inject llm llm-ollama
        pipx ensurepath
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# 7. llm-micro Plugin
PLUGIN_DIR="$HOME/.config/micro/plug/llm"
if [ ! -d "$PLUGIN_DIR" ]; then
    if ask_prompt "Install LLM plugin and configure bindings?" "Y"; then
        mkdir -p "$HOME/.config/micro/plug"
        git clone https://github.com/shamanicvocalarts/llm-micro "$PLUGIN_DIR"

        BINDINGS_FILE="$HOME/.config/micro/bindings.json"
        # If Micro was already installed, preserve prior bindings before modification.
        if [[ "$MICRO_PREEXISTING" == "true" ]] && [[ -f "$BINDINGS_FILE" ]]; then
            TS="$(date +%Y%m%d_%H%M%S)"
            cp "$BINDINGS_FILE" "${BINDINGS_FILE}.bak.${TS}"
            echo -e "${YELLOW}Backed up existing bindings.json to ${BINDINGS_FILE}.bak.${TS}${NC}"
        fi
        [[ -f "$BINDINGS_FILE" ]] || echo "{}" > "$BINDINGS_FILE"

        python3 - <<EOF
import json, os
path = os.path.expanduser("$BINDINGS_FILE")
try:
    with open(path, 'r') as f:
        data = json.load(f)
except Exception:
    data = {}
data.update({"Alt-a": "command-edit:llm ", "Alt-c": "command-edit:chat "})
with open(path, 'w') as f:
    json.dump(data, f, indent=4)
EOF
    fi
fi

# 8. Model Pulling
if ask_prompt "Pull llama3.2:1b?" "Y"; then
    pgrep -x "ollama" > /dev/null || (ollama serve > /dev/null 2>&1 & sleep 5)
    ollama pull llama3.2:1b
    llm models default llama3.2:1b
fi

# 9. Permanent Path Fix
if [[ -f "$HOME/.bashrc" ]]; then
    if ! grep -q ".local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
else
    echo -e "${YELLOW}Note: ~/.bashrc not found; PATH persistence skipped. Ensure ~/.local/bin is in PATH for future shells.${NC}"
fi

echo -e "\n${GREEN}=== Setup Complete! ===${NC}"
echo -e "To start using the commands in this terminal session, run:"
echo -e "${YELLOW}source ~/.bashrc${NC}"
echo -e "\nThen open Micro and use ${YELLOW}Alt-a${NC} for AI help."
