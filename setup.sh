#!/usr/bin/env bash

set -euo pipefail

if ! command -v dnf >/dev/null; then
  echo "dnf not found"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

DNF_PKGS=(
  # system
  jetbrains-mono-fonts

  # gui
  kitty chromium virt-manager

  # tui
  neovim lazygit

  # terminal utils
  bat fd btop fzf ripgrep stow curl wget unzip wl-clipboard fastfetch
  tree-sitter-cli

  # c/c++
  clang clang-tools-extra gcc cmake ninja valgrind gdb SDL3-devel
  SDL3_image-devel SDL3_ttf-devel

  # rust
  rustup

  # python
  python-lsp-server
)

install_codecs() {
  sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
  sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
  sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
}

setup_home() {
  mkdir -p "$HOME/repos/"
  sudo dnf install -y "${DNF_PKGS[@]}"
  stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
}

read -p "Install multimedia codecs? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  install_codecs
fi

setup_home
