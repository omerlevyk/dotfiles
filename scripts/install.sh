#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Dotfiles installer
# - Installs packages from packages/{apt,pacman,brew}.txt
# - Creates symlinks for configs
# - Safe: backs up existing files with .bak-<timestamp>
# ----------------------------

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$REPO_ROOT/packages"
CONFIG_DIR="$REPO_ROOT/config"
SHELL_DIR="$REPO_ROOT/shell"
GIT_DIR="$REPO_ROOT/git"

DRY_RUN=0
SKIP_PACKAGES=0
SKIP_LINKS=0

timestamp() { date +"%Y%m%d-%H%M%S"; }

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --dry-run          Print actions without executing (recommended first)
  --skip-packages    Do not install packages
  --skip-links       Do not create symlinks
  -h, --help         Show help

Examples:
  $0 --dry-run
  $0
  $0 --skip-packages
EOF
}

log() { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[x]\033[0m %s\n" "$*"; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY-RUN: $*"
  else
    eval "$@"
  fi
}

# ----------------------------
# Parse args
# ----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  --skip-packages)
    SKIP_PACKAGES=1
    shift
    ;;
  --skip-links)
    SKIP_LINKS=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    err "Unknown option: $1"
    usage
    exit 1
    ;;
  esac
done

# ----------------------------
# Detect platform / package manager
# ----------------------------
OS="$(uname -s)"
PKG_MGR=""
PKG_FILE=""

detect_pkg_mgr() {
  if [[ "$OS" == "Darwin" ]]; then
    PKG_MGR="brew"
    PKG_FILE="$PACKAGES_DIR/brew.txt"
    return
  fi

  # Linux
  if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
    PKG_FILE="$PACKAGES_DIR/apt.txt"
    return
  fi
  if command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
    PKG_FILE="$PACKAGES_DIR/pacman.txt"
    return
  fi

  PKG_MGR="none"
  PKG_FILE=""
}

detect_pkg_mgr

# ----------------------------
# Helpers
# ----------------------------
read_packages() {
  local file="$1"
  [[ -f "$file" ]] || {
    err "Packages file not found: $file"
    exit 1
  }
  # Remove comments + blank lines
  grep -vE '^\s*#' "$file" | sed '/^\s*$/d' || true
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local bak="${target}.bak-$(timestamp)"
    warn "Backing up: $target -> $bak"
    run "mv \"$target\" \"$bak\""
  fi
}

link_one() {
  local src="$1"
  local dest="$2"

  # Ensure parent dir exists
  local parent
  parent="$(dirname "$dest")"
  run "mkdir -p \"$parent\""

  # If already correct symlink, skip
  if [[ -L "$dest" ]]; then
    local cur
    cur="$(readlink -f "$dest" || true)"
    local want
    want="$(readlink -f "$src" || true)"
    if [[ "$cur" == "$want" ]]; then
      log "Link ok: $dest -> $src"
      return
    fi
  fi

  backup_if_exists "$dest"
  log "Link: $dest -> $src"
  run "ln -s \"$src\" \"$dest\""
}

# ----------------------------
# Install packages
# ----------------------------
install_packages() {
  if [[ "$PKG_MGR" == "none" ]]; then
    warn "No supported package manager found. Skipping packages."
    return
  fi

  if [[ ! -f "$PKG_FILE" ]]; then
    warn "Packages file missing ($PKG_FILE). Skipping packages."
    return
  fi

  log "Using package manager: $PKG_MGR"
  log "Packages file: $PKG_FILE"

  mapfile -t pkgs < <(read_packages "$PKG_FILE")
  if [[ "${#pkgs[@]}" -eq 0 ]]; then
    warn "No packages found in $PKG_FILE"
    return
  fi

  case "$PKG_MGR" in
  apt)
    log "Updating apt..."
    run "sudo apt-get update"
    log "Installing packages..."
    run "sudo apt-get install -y ${pkgs[*]}"
    ;;
  pacman)
    log "Syncing pacman..."
    run "sudo pacman -Sy --noconfirm"
    log "Installing packages..."
    run "sudo pacman -S --noconfirm --needed ${pkgs[*]}"
    ;;
  brew)
    if ! command -v brew >/dev/null 2>&1; then
      err "Homebrew not found. Install brew first, then rerun."
      exit 1
    fi
    log "Updating brew..."
    run "brew update"
    log "Installing packages..."
    run "brew install ${pkgs[*]}"
    ;;
  esac

  # Ubuntu special-case: fd-find provides 'fdfind' binary, many tools expect 'fd'
  if [[ "$PKG_MGR" == "apt" ]] && command -v fdfind >/dev/null 2>&1; then
    if ! command -v fd >/dev/null 2>&1; then
      log "Creating fd symlink (Ubuntu): ~/.local/bin/fd -> fdfind"
      run "mkdir -p \"$HOME/.local/bin\""
      run "ln -s \"$(command -v fdfind)\" \"$HOME/.local/bin/fd\""
    fi
  fi
}

# ----------------------------
# Create symlinks for dotfiles
# ----------------------------
link_dotfiles() {
  log "Linking dotfiles from: $REPO_ROOT"

  # ~/.config/*
  # You already use this pattern: ~/.config/<name> -> ~/dotfiles/config/<name>
  local configs=(i3 polybar rofi picom nvim ohmyposh)
  for name in "${configs[@]}"; do
    if [[ -d "$CONFIG_DIR/$name" ]]; then
      link_one "$CONFIG_DIR/$name" "$HOME/.config/$name"
    else
      warn "Missing in repo (skip): config/$name"
    fi
  done

  # screenlayout
  if [[ -d "$CONFIG_DIR/screenlayout" ]]; then
    link_one "$CONFIG_DIR/screenlayout" "$HOME/.screenlayout"
  fi

  # tmux: ~/.tmux.conf -> ~/dotfiles/config/tmux/tmux.conf
  if [[ -f "$CONFIG_DIR/tmux/tmux.conf" ]]; then
    link_one "$CONFIG_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
  fi

  # bashrc
  if [[ -f "$SHELL_DIR/bashrc" ]]; then
    link_one "$SHELL_DIR/bashrc" "$HOME/.bashrc"
  fi

}

# ----------------------------
# Run
# ----------------------------
log "Repo: $REPO_ROOT"
log "Dry-run: $DRY_RUN"

if [[ "$SKIP_PACKAGES" -eq 0 ]]; then
  install_packages
else
  warn "Skipping packages (--skip-packages)."
fi

if [[ "$SKIP_LINKS" -eq 0 ]]; then
  link_dotfiles
else
  warn "Skipping symlinks (--skip-links)."
fi

log "Done."
