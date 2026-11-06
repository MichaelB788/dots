#!/usr/bin/env bash

set -euo pipefail

if ! command -v pacman >/dev/null; then
  echo "pacman not found"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

PACMAN_PKGS=(
  # system
  ttf-jetbrains-mono-nerd

  # gui
  firefox chromium virt-manager dolphin zed

  # tui
  neovim lazygit

  # terminal utils
  bat less man fd btop fzf ripgrep stow curl wget unzip wl-clipboard fastfetch
  tree-sitter-cli

  # c/c++
  clang gcc cmake ninja valgrind gdb sdl3 sdl3_ttf sdl3_image

  # rust
  rustup

  # python
  python-lsp-server
)

mkdir -p "$HOME/repos/"
sudo pacman -S "${PACMAN_PKGS[@]}" --needed
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
