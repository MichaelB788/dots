#!/usr/bin/env bash

set -euo pipefail

if ! command -v pacman >/dev/null; then
  echo "pacman not found"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

DNF_PKGS=(
  # sway
  sway wmenu grim swaylock swayidle swaybg mako slurp ttf-jetbrains-mono-nerd
  wl-clipboard xdg-desktop-portal-wlr thunar-volman gvfs

  # gui
  kitty azote nwg-look wireshark-qt firefox virt-manager chromium
  thunar

  # tui
  lazygit neovim bluetui wiremix rtorrent

  # terminal utils
  fastfetch fzf ripgrep stow curl wget unzip btop tree-sitter-cli man less
  bash-completion

  # c/c++
  clang gcc cmake ninja sdl3 sdl3_image sdl3_ttf

  # rust
  rustup

  # python
  python-lsp-server
)

WALLPAPERS=(
    "https://w.wallhaven.cc/full/5w/wallhaven-5wmm57.jpg"
    "https://w.wallhaven.cc/full/xe/wallhaven-xe9g8l.jpg"
    "https://w.wallhaven.cc/full/6l/wallhaven-6ly5g6.jpg"
)

mkdir -p "$HOME"/{.config,img,repos}
sudo pacman -S "${DNF_PKGS[@]}"
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
wget -nc -P "$HOME/img" "${WALLPAPERS[@]}"
