# macOS 15.6.1 Dotfiles

This directory contains configuration files for my personal macOS development environment, including `~/.zshrc` and related shell configurations. The goal is to maintain a **minimal, UNIX-like workflow** on my primary working device, prioritizing simplicity, reliability, and efficiency.

---

## Overview

The environment is designed according to the principles of **pragmatic minimalism**:

- Leverage built-in system tools wherever possible.  
- Keep configuration simple and lightweight.  
- Ensure reliability and safety (e.g., prevent double clock-ins or data loss).  
- Preserve all historical records (append-only timesheets).  

This setup is intended for personal use and is tuned specifically for macOS 16.5.1, but it uses standard POSIX/macOS utilities and should work in similar UNIX-like environments.

---

## Features

### Workspace Navigation

- **Alias:** `workspace` — quickly navigate to the main development folder (`~/Documents/Workspace`).

### Time Tracking

A lightweight timesheet/timeclock system is built directly into the shell:

- Active timesheet file: `~/.timeclock`  
- Archived timesheets folder: `~/.timesheets/`  

#### Commands

- `timesheet` — Display the current active timesheet.  
- `timesheets` — List all archived timesheets.  
- `clockin` — Record a clock-in timestamp. Prevents double clock-ins and optionally allows specifying hours to close the previous session.  
- `clockout` — Record a clock-out timestamp. Prevents double clock-outs.  
- `clswk` — Close and archive the current timesheet. If a session is active, prompts to clock out before archiving.  
- `tscomm <comment>` — Append a free-text comment to the current timesheet.

**Implementation Notes:**

- The system is **append-only**; no entries are deleted.  
- When a new session is started, the most recent clock-in entry is used to compute elapsed time if necessary.  
- User prompts ensure accidental overwrites or invalid entries are avoided.

### Development Tools

- `awsprofile <profile>` — Switch AWS CLI profiles quickly.  
- `repomix` — Run the RepoMix Docker container for repository-based Markdown transformations.

---

## Philosophy

This environment is intentionally **minimal and focused**. It is not intended to provide a comprehensive suite of utilities, but rather to:

- Reduce cognitive overhead.  
- Enable lightweight, reliable workflow management.  
- Preserve historical records safely and transparently.  

The approach emphasizes **pragmatic minimalism**: do more with less, using tools already available in the system, with safety and reliability as first priorities.

---

## Installation and Usage

1. Copy `.zshrc` to `~/.zshrc`.  
2. Ensure that `~/.profile` exists and is sourced for base environment setup.  
3. Reload the shell configuration:

```bash
source ~/.zshrc