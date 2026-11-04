#!/usr/bin/env bash

set -euo pipefail

if ! command -v dnf >/dev/null; then
  echo "Did not find dnf"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

DNF_PKGS=(
  # sway
  sway wmenu grim swaylock swaybg mako slurp jetbrains-mono-fonts wl-clipboard
  xdg-desktop-portal-wlr plasma-breeze

  # gui
  kitty azote nwg-look wireshark firefox qbittorrent virt-manager chromium

  # tui
  lazygit neovim

  # terminal utils
  fastfetch fzf ripgrep stow curl wget unzip btop tree-sitter-cli

  # c/c++
  clang clang-tools-extra gcc g++ cmake ninja SDL3-devel SDL3_image-devel
  SDL3_ttf-devel

  # rust
  rustup

  # python
  python3-lsp-server
)

WALLPAPERS=(
    "https://w.wallhaven.cc/full/5w/wallhaven-5wmm57.jpg"
    "https://w.wallhaven.cc/full/xe/wallhaven-xe9g8l.jpg"
    "https://w.wallhaven.cc/full/6l/wallhaven-6ly5g6.jpg"
)

install_codecs() {
  sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
  sudo dnf group upgrade multimedia -y
  sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
  sudo dnf group upgrade core -y
  sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
}

setup_home() {
  sudo dnf install -y "${DNF_PKGS[@]}"
  stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
  wget -nc -P "$HOME/Pictures" "${WALLPAPERS[@]}"
}

read -p "Install media codecs? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  install_codecs
fi

setup_home
