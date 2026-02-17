#!/bin/bash

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Debian Trixie Micro Local LLM Setup (Interactive) ===${NC}"

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
else
    echo -e "${GREEN}Detected 'trixie' in /etc/os-release.${NC}"
fi

# 2. Architecture & Immediate Path Prep
ARCH=$(uname -m)
echo -e "System Architecture: ${YELLOW}$ARCH${NC}"
# This makes the rest of the script work without manual sourcing
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# Track whether Micro was already installed before we touch anything (used for bindings backup policy).
MICRO_PREEXISTING=false
if command -v micro &> /dev/null; then
    MICRO_PREEXISTING=true
fi

# 3. Dependency Installation (Apt)
echo -e "\n${GREEN}Installing system dependencies...${NC}"
sudo apt update
sudo apt install -y curl git python3-pip xclip python3-venv pipx zstd procps

# 4. Micro Text Editor
if command -v micro &> /dev/null; then
    echo -e "${GREEN}Micro already installed. Skipping.${NC}"
else
    if ask_prompt "Install Micro Text Editor?" "Y"; then
        sudo apt install -y micro
        echo -e "${GREEN}Micro installed.${NC}"
    else
        echo -e "${YELLOW}Micro install skipped by user.${NC}"
    fi
fi

# 5. Ollama Inference Engine
if command -v ollama &> /dev/null; then
    echo -e "${GREEN}Ollama already installed. Skipping.${NC}"
else
    if ask_prompt "Install Ollama (via official upstream installer script)?" "Y"; then
        curl -fsSL https://ollama.com/install.sh | sh
        echo -e "${GREEN}Ollama installed.${NC}"

        # Non-systemd / container fallback: start Ollama in background opportunistically.
        if ! command -v systemctl &> /dev/null || ! systemctl is-system-running &> /dev/null; then
            echo -e "${YELLOW}Non-systemd environment detected. Starting Ollama in background...${NC}"
            ollama serve > /dev/null 2>&1 &
            sleep 5
            if pgrep -x "ollama" > /dev/null; then
                echo -e "${GREEN}Ollama is running.${NC}"
            else
                echo -e "${YELLOW}Ollama did not appear to start. You may need to run 'ollama serve' manually.${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}Ollama install skipped by user.${NC}"
    fi
fi

# 6. LLM CLI Installation
if command -v llm &> /dev/null; then
    echo -e "${GREEN}llm CLI already installed. Skipping.${NC}"
else
    echo -e "\n${YELLOW}Python Environment Choice:${NC}"
    echo "1) [Recommended] pipx (Isolated, safe for Debian/PEP 668)"
    echo "2) --break-system-packages (Direct, risky)"
    read -r -p "Select [1/2] (Default 1): " py_choice

    if [[ "$py_choice" == "2" ]]; then
        echo -e "${YELLOW}Installing llm via pip with --break-system-packages...${NC}"
        pip install llm llm-ollama --break-system-packages
    else
        echo -e "${YELLOW}Installing llm via pipx...${NC}"
        pipx install llm
        pipx inject llm llm-ollama
        pipx ensurepath
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if command -v llm &> /dev/null; then
        echo -e "${GREEN}llm CLI installed and available.${NC}"
    else
        echo -e "${YELLOW}llm CLI not found on PATH yet. You may need to source your shell rc file or open a new shell.${NC}"
    fi
fi

# 7. llm-micro Plugin + Bindings
PLUGIN_DIR="$HOME/.config/micro/plug/llm"
BINDINGS_FILE="$HOME/.config/micro/bindings.json"

if [ -d "$PLUGIN_DIR" ]; then
    echo -e "${GREEN}llm-micro plugin already present at:${NC} ${YELLOW}$PLUGIN_DIR${NC}"
else
    if ask_prompt "Install llm-micro plugin and configure bindings?" "Y"; then
        mkdir -p "$HOME/.config/micro/plug"
        git clone https://github.com/shamanicvocalarts/llm-micro "$PLUGIN_DIR"
        echo -e "${GREEN}llm-micro plugin installed.${NC}"
    else
        echo -e "${YELLOW}Plugin install skipped by user.${NC}"
    fi
fi

# Configure bindings if plugin exists (or if user chose to install it above)
if [ -d "$PLUGIN_DIR" ]; then
    # Backup bindings.json only if Micro was already installed AND bindings existed before modification.
    if [[ "$MICRO_PREEXISTING" == "true" ]] && [[ -f "$BINDINGS_FILE" ]]; then
        TS="$(date +%Y%m%d_%H%M%S)"
        cp "$BINDINGS_FILE" "${BINDINGS_FILE}.bak.${TS}"
        echo -e "${YELLOW}Backed up existing bindings.json to:${NC} ${YELLOW}${BINDINGS_FILE}.bak.${TS}${NC}"
    fi

    [ ! -f "$BINDINGS_FILE" ] && echo "{}" > "$BINDINGS_FILE"

    python3 - <<EOF
import json, os
path = os.path.expanduser("$BINDINGS_FILE")
try:
    with open(path, "r") as f:
        data = json.load(f)
except Exception:
    data = {}
# Overwrite by design (documented behavior)
data.update({"Alt-a": "command-edit:llm ", "Alt-c": "command-edit:chat "})
with open(path, "w") as f:
    json.dump(data, f, indent=4)
EOF
    echo -e "${GREEN}Updated Micro bindings:${NC} ${YELLOW}Alt-a${NC}, ${YELLOW}Alt-c${NC}"
else
    echo -e "${YELLOW}Skipping bindings configuration because llm-micro plugin is not installed.${NC}"
fi

# 8. Model Pulling (Tag-Based Selection Menu)
echo -e "\n${YELLOW}Select LLM model to pull (tag-based; may change over time).${NC}"
echo "Press Enter for default 1, or type 0 to skip."
echo ""
echo "1) llama3.2:1b (~700 MB)"
echo "2) qwen2.5-coder:1.5b (~950 MB)"
echo "3) gemma2:2b (~1.6 GB)"
echo "4) llama3.2:3b (~2.0 GB)"
echo "5) gemma2:2b-instruct-q8_0 (~2.6 GB)"
echo ""

model_choice=""
while true; do
    read -r -p "Select [1-5] (Default 1): " model_choice
    model_choice="${model_choice:-1}"
    if [[ "$model_choice" == "0" ]]; then
        echo -e "${YELLOW}Skipping model pull.${NC}"
        MODEL=""
        break
    fi
    if [[ "$model_choice" =~ ^[1-5]$ ]]; then
        break
    fi
    echo -e "${RED}Invalid selection. Enter 1-5, press Enter for default (1), or enter 0 to skip.${NC}"
done

if [[ -n "${MODEL:-}" ]]; then
    : # MODEL already set by skip path
else
    case "$model_choice" in
        1) MODEL="llama3.2:1b" ;;
        2) MODEL="qwen2.5-coder:1.5b" ;;
        3) MODEL="gemma2:2b" ;;
        4) MODEL="llama3.2:3b" ;;
        5) MODEL="gemma2:2b-instruct-q8_0" ;;
        *) MODEL="llama3.2:1b" ;;
    esac
fi

if [[ -n "${MODEL}" ]]; then
    echo -e "${GREEN}Selected model:${NC} ${YELLOW}${MODEL}${NC}"

    # Ensure Ollama is running (opportunistic background start if needed)
    if command -v ollama &> /dev/null; then
        if ! pgrep -x "ollama" > /dev/null; then
            echo -e "${YELLOW}Ollama is not running. Starting in background...${NC}"
            ollama serve > /dev/null 2>&1 &
            sleep 5
        fi
        if pgrep -x "ollama" > /dev/null; then
            echo -e "${GREEN}Pulling model:${NC} ${YELLOW}${MODEL}${NC}"
            ollama pull "$MODEL"
            if command -v llm &> /dev/null; then
                echo -e "${GREEN}Setting default llm model to:${NC} ${YELLOW}${MODEL}${NC}"
                llm models default "$MODEL"
            else
                echo -e "${YELLOW}llm not found; cannot set default model automatically.${NC}"
            fi
        else
            echo -e "${YELLOW}Ollama did not start. Skipping model pull. You can run 'ollama serve' and pull manually.${NC}"
        fi
    else
        echo -e "${YELLOW}Ollama not installed; skipping model pull.${NC}"
    fi
fi

# 9. Permanent Path Fix (Bash-targeted)
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q ".local/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo -e "${GREEN}Updated ~/.bashrc to include ~/.local/bin in PATH.${NC}"
    else
        echo -e "${GREEN}~/.bashrc already contains ~/.local/bin PATH entry. Skipping.${NC}"
    fi
else
    echo -e "${YELLOW}Note: ~/.bashrc not found; PATH persistence skipped. Ensure ~/.local/bin is in PATH for future shells.${NC}"
fi

# 10. Completion Summary (Operator Visibility)
echo -e "\n${GREEN}=== Setup Complete! ===${NC}"

echo -e "\n${GREEN}=== Summary ===${NC}"
echo -e "Architecture: ${YELLOW}${ARCH}${NC}"
echo -e "Ollama available: $(command -v ollama >/dev/null 2>&1 && echo Yes || echo No)"
echo -e "llm available:    $(command -v llm >/dev/null 2>&1 && echo Yes || echo No)"
echo -e "Plugin present:   $([ -d "$PLUGIN_DIR" ] && echo Yes || echo No)"
echo -e "Model selected:   ${YELLOW}${MODEL:-none}${NC}"

if [ -f "$HOME/.bashrc" ]; then
    echo -e "\nTo refresh your shell PATH, run:"
    echo -e "${YELLOW}source ~/.bashrc${NC}"
else
    echo -e "\n${YELLOW}~/.bashrc not present. Open a new shell session to ensure PATH is correct.${NC}"
fi

echo -e "\nThen open Micro and use ${YELLOW}Alt-a${NC} for AI help."
