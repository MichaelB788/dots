#!/usr/bin/env bash

set -euo pipefail

if ! command -v pacman >/dev/null; then
  echo "Not an Arch based system."
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)
WALLPAPERS=(
    "https://w.wallhaven.cc/full/xe/wallhaven-xe9g8l.jpg"
    "https://w.wallhaven.cc/full/6l/wallhaven-6ly5g6.jpg"
    "https://w.wallhaven.cc/full/wy/wallhaven-wylxpx.png"
)

xargs -a "$DOTFILES_PATH/pkgs.txt" sudo pacman -S

mkdir -p "$HOME/.config"
rm -f "$HOME/.bashrc"
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules

wget -nc -P "$HOME/Pictures" "${WALLPAPERS[@]}"
