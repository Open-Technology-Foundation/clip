#!/usr/bin/env bash
#shellcheck disable=SC2015,SC2034
# SC2015: Safe usage of && || pattern for color variable initialization
# SC2034: REPO_URL and use_remote reserved for future enhancement (remote download)
# install.sh - Installation script for clip utility
#
# This script provides an interactive installer that can:
# - Auto-detect system vs user installation
# - Download clip if not present
# - Install dependencies (xclip)
# - Set up bash completion
# - Handle both sudo and non-sudo installations
#
# Usage:
#   Local:  ./install.sh
#   Remote: curl -sSL https://raw.githubusercontent.com/Open-Technology-Foundation/clip/main/install.sh | bash
#
# Version: 1.0.1
# License: GPL-3.0

set -euo pipefail
shopt -s inherit_errexit

# Script metadata
declare -r VERSION='1.0.1'
declare -r REPO_URL='https://github.com/Open-Technology-Foundation/clip'
declare -r RAW_URL='https://raw.githubusercontent.com/Open-Technology-Foundation/clip/main'

# Installation directories
declare -r SYSTEM_BINDIR='/usr/local/bin'
declare -r SYSTEM_COMPDIR='/usr/local/share/bash-completion/completions'
declare -r SYSTEM_MANDIR='/usr/local/share/man/man1'
declare -r USER_BINDIR="$HOME/.local/bin"
declare -r USER_COMPDIR="$HOME/.local/share/bash-completion/completions"
declare -r USER_MANDIR="$HOME/.local/share/man/man1"

# Files to install
declare -r SCRIPT='clip'
declare -r COMPLETION='clip.bash_completion'
declare -r MANPAGE='clip.1'

# Color support
[[ -t 2 ]] && declare -r GREEN=$'\033[0;32m' CYAN=$'\033[0;36m' YELLOW=$'\033[0;33m' RED=$'\033[0;31m' NC=$'\033[0m' || declare -r GREEN='' CYAN='' YELLOW='' RED='' NC=''

# Messaging functions
info() { >&2 echo "${CYAN}◉${NC} $*"; }
success() { >&2 echo "${GREEN}✓${NC} $*"; }
warn() { >&2 echo "${YELLOW}▲${NC} $*"; }
error() { >&2 echo "${RED}✗${NC} $*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-1}"; }

# Yes/no prompt
yn() {
  local -- REPLY
  >&2 read -r -n 1 -p "$(echo -e "${CYAN}◉${NC} ${1:-'Continue?'}") ${CYAN}[y/N]${NC} "
  >&2 echo
  [[ ${REPLY,,} == y ]]
}

# Detect if running with sudo/root
is_root() {
  [[ $EUID -eq 0 ]]
}

# Check if command exists
has_command() {
  command -v "$1" &>/dev/null
}

# Download file from GitHub
download_file() {
  local -- url=$1 dest=$2
  if has_command curl; then
    curl -sSL "$url" -o "$dest"
  elif has_command wget; then
    wget -q "$url" -O "$dest"
  else
    die 1 "Neither curl nor wget is available. Cannot download files."
  fi
}

# Install dependencies
install_dependencies() {
  if has_command xclip; then
    info "xclip is already installed"
    return 0
  fi

  info "xclip is required for clipboard operations"

  if ! yn "Install xclip?"; then
    die 1 "Installation aborted. xclip is required."
  fi

  if has_command apt-get; then
    if is_root; then
      apt-get update -qq && apt-get install -y xclip
    else
      sudo apt-get update -qq && sudo apt-get install -y xclip
    fi
    success "xclip installed"
  else
    warn "apt-get not found. Please install xclip manually:"
    echo "  https://github.com/astrand/xclip"
    if ! yn "Continue without installing xclip?"; then
      die 1 "Installation aborted"
    fi
  fi
}

# System-wide installation (requires root)
install_system() {
  local -- script_src=$1 completion_src=$2 manpage_src=$3

  if ! is_root; then
    die 1 "System-wide installation requires root privileges" \
          "Run with sudo: sudo $0"
  fi

  info "Installing clip v$VERSION (system-wide)..."

  # Create directories
  install -d "$SYSTEM_BINDIR"
  install -d "$SYSTEM_COMPDIR"
  install -d "$SYSTEM_MANDIR"

  # Remove existing installation if present
  rm -f "$SYSTEM_BINDIR/$SCRIPT"
  rm -f "$SYSTEM_COMPDIR/$SCRIPT"
  rm -f "$SYSTEM_MANDIR/$MANPAGE.gz"

  # Install files
  install -m 755 "$script_src" "$SYSTEM_BINDIR/$SCRIPT"
  install -m 644 "$completion_src" "$SYSTEM_COMPDIR/$SCRIPT"
  install -m 644 "$manpage_src" "$SYSTEM_MANDIR/$MANPAGE"

  # Compress man page
  gzip -f "$SYSTEM_MANDIR/$MANPAGE"

  success "Installation complete!"
  echo ""
  echo "Installed files:"
  echo "  $SYSTEM_BINDIR/$SCRIPT"
  echo "  $SYSTEM_COMPDIR/$SCRIPT"
  echo "  $SYSTEM_MANDIR/$MANPAGE.gz"
  echo ""
  echo "Usage:"
  echo "  man clip                         # View manual page"
  echo "  source $SYSTEM_COMPDIR/$SCRIPT   # Enable bash completion"
}

# User-level installation (no root required)
install_user() {
  local -- script_src=$1 completion_src=$2 manpage_src=$3

  info "Installing clip v$VERSION (user-level)..."

  # Create directories
  mkdir -p "$USER_BINDIR"
  mkdir -p "$USER_COMPDIR"
  mkdir -p "$USER_MANDIR"

  # Remove existing installation if present
  rm -f "$USER_BINDIR/$SCRIPT"
  rm -f "$USER_COMPDIR/$SCRIPT"
  rm -f "$USER_MANDIR/$MANPAGE.gz"

  # Install files
  install -m 755 "$script_src" "$USER_BINDIR/$SCRIPT"
  install -m 644 "$completion_src" "$USER_COMPDIR/$SCRIPT"
  install -m 644 "$manpage_src" "$USER_MANDIR/$MANPAGE"

  # Compress man page
  gzip -f "$USER_MANDIR/$MANPAGE"

  # Add ~/.local/bin to PATH if not present
  if ! echo "$PATH" | grep -q "$USER_BINDIR"; then
    if [[ -f ~/.bashrc ]]; then
      if ! grep -q "export PATH=\"$USER_BINDIR" ~/.bashrc; then
        {
          echo ""
          echo "# Add ~/.local/bin to PATH for clip"
          echo "export PATH=\"$USER_BINDIR:\$PATH\""
        } >> ~/.bashrc
        info "Added $USER_BINDIR to PATH in ~/.bashrc"
      fi
    else
      warn "$USER_BINDIR is not in your PATH"
      echo "  Add this to your shell profile:"
      echo "    export PATH=\"$USER_BINDIR:\$PATH\""
    fi
  fi

  # Setup bash completion
  if [[ -f ~/.bashrc ]]; then
    if ! grep -q "$USER_COMPDIR/$SCRIPT" ~/.bashrc; then
      {
        echo ""
        echo "# clip bash completion"
        echo "[ -f $USER_COMPDIR/$SCRIPT ] && source $USER_COMPDIR/$SCRIPT"
      } >> ~/.bashrc
      info "Added bash completion to ~/.bashrc"
    fi
  fi

  # Setup MANPATH
  if [[ -f ~/.bashrc ]]; then
    if ! grep -q "MANPATH.*$USER_MANDIR" ~/.bashrc; then
      {
        echo ""
        echo "# Add ~/.local/share/man to MANPATH for clip"
        echo "export MANPATH=\"$HOME/.local/share/man:\$MANPATH\""
      } >> ~/.bashrc
      info "Added MANPATH to ~/.bashrc"
    fi
  fi

  success "Installation complete!"
  echo ""
  echo "Installed files:"
  echo "  $USER_BINDIR/$SCRIPT"
  echo "  $USER_COMPDIR/$SCRIPT"
  echo "  $USER_MANDIR/$MANPAGE.gz"
  echo ""
  echo "To use immediately:"
  echo "  export PATH=\"$USER_BINDIR:\$PATH\""
  echo "  export MANPATH=\"$HOME/.local/share/man:\$MANPATH\""
  echo "  source $USER_COMPDIR/$SCRIPT"
  echo ""
  echo "Or restart your shell to apply changes"
}

# Main installation function
main() {
  local -- script_file completion_file manpage_file
  local -- temp_dir=''
  local -i use_remote=0

  echo ""
  echo "${GREEN}clip${NC} v$VERSION - Installation Script"
  echo ""

  # Check if we're in the clip repository
  if [[ -f "$SCRIPT" ]] && [[ -f "$COMPLETION" ]] && [[ -f "$MANPAGE" ]]; then
    info "Found clip files in current directory"
    script_file="$SCRIPT"
    completion_file="$COMPLETION"
    manpage_file="$MANPAGE"
  else
    # Need to download from GitHub
    info "Downloading clip from GitHub..."
    use_remote=1

    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT ERR

    script_file="$temp_dir/$SCRIPT"
    completion_file="$temp_dir/$COMPLETION"
    manpage_file="$temp_dir/$MANPAGE"

    download_file "$RAW_URL/$SCRIPT" "$script_file"
    download_file "$RAW_URL/$COMPLETION" "$completion_file"
    download_file "$RAW_URL/$MANPAGE" "$manpage_file"
    chmod +x "$script_file"

    success "Downloaded clip v$VERSION"
  fi

  # Install dependencies
  install_dependencies

  # Determine installation type
  if is_root; then
    info "Running as root - will install system-wide"
    if yn "Install system-wide to $SYSTEM_BINDIR?"; then
      install_system "$script_file" "$completion_file" "$manpage_file"
    else
      die 0 "Installation cancelled"
    fi
  else
    echo "Choose installation type:"
    echo "  1) User installation (no sudo, installs to ~/.local/bin)"
    echo "  2) System installation (requires sudo, installs to /usr/local/bin)"
    echo ""
    read -r -p "$(echo -e "${CYAN}◉${NC} Select [1-2]: ")" choice

    case "$choice" in
      1)
        install_user "$script_file" "$completion_file" "$manpage_file"
        ;;
      2)
        if ! has_command sudo; then
          die 1 "sudo is not available. Use option 1 for user installation."
        fi
        info "Requesting sudo privileges for system installation..."
        sudo -v || die 1 "sudo authentication failed"
        sudo "$0" --system "$script_file" "$completion_file" "$manpage_file"
        return 0
        ;;
      *)
        die 1 "Invalid selection"
        ;;
    esac
  fi

  # Verify installation
  echo ""
  info "Verifying installation..."

  local -- clip_path
  if is_root || [[ ${choice:-} == 2 ]]; then
    clip_path="$SYSTEM_BINDIR/$SCRIPT"
  else
    clip_path="$USER_BINDIR/$SCRIPT"
  fi

  if [[ -x "$clip_path" ]]; then
    success "Installation verified: $clip_path"
    echo ""
    "$clip_path" -V
  else
    warn "Installation may have issues. Run '$SCRIPT -V' to verify."
  fi
}

# Handle --system flag (internal use by sudo)
if [[ ${1:-} == "--system" ]] && [[ $# -eq 4 ]]; then
  install_system "$2" "$3" "$4"
  exit 0
fi

main "$@"

#fin
