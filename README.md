# Dotfiles

Personal dotfiles for a **Linux i3-based workflow**, focused on a clean, minimal, and reproducible setup.

The goal of this repository is to:
- Fully restore my working environment on a new machine
- Keep configuration declarative and version-controlled
- Stay cross-distro friendly (Ubuntu / Arch / macOS CLI)

---

## Supported Systems

- **Ubuntu / Debian** (apt)
- **Arch / EndeavourOS / Manjaro** (pacman)
- **macOS** (brew – CLI tools only)

---

## What’s Included

### Window Manager & UI
- **i3** – window manager
- **polybar** – status bar
- **rofi** – application launcher
- **picom** – compositor
- **screenlayout** – xrandr scripts for multi-monitor setups

### Terminal & Shell
- **bash** – structured `.bashrc`
- **tmux** – terminal multiplexer
- **oh-my-posh** – prompt engine (gruvbox theme)

### Editor
- **neovim** – Lua-based config (Lazy-style, config only)
- **vim** – basic vim config

### Dev & CLI Tools
- **git**
- **ripgrep**
- **fd / fdfind**
- **fzf**

---

## Repository Structure

```text
dotfiles/
├── config/
│   ├── i3/
│   ├── tmux/
│   ├── polybar/
│   ├── rofi/
│   ├── picom/
│   ├── nvim/
│   ├── vim/
│   ├── ohmyposh/
│   └── screenlayout/
│
├── shell/
│   ├── bashrc
│   ├── aliases.sh
│   ├── env.sh
│   ├── exports
│   ├── prompt.sh
│   └── tmux.sh
│
├── packages/
│   ├── apt.txt
│   ├── pacman.txt
│   ├── brew.txt
│   └── pipx.txt
│
├── scripts/
│   └── install.sh
│
└── README.md

