#!/usr/bin/env bash

set -euo pipefail

if ! command -v dnf >/dev/null; then
  echo "Not a Fedora based system."
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)
FONT_PATH="$HOME/.local/share/fonts"
WALLPAPERS=(
    "https://w.wallhaven.cc/full/xe/wallhaven-xe9g8l.jpg"
    "https://w.wallhaven.cc/full/6l/wallhaven-6ly5g6.jpg"
    "https://w.wallhaven.cc/full/wy/wallhaven-wylxpx.png"
)

xargs -a "$DOTFILES_PATH/pkgs.txt" sudo dnf install -y
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
wget -nc -P "$HOME/Pictures" "${WALLPAPERS[@]}"

if [ ! -d "$FONT_PATH/JetBrainsMono" ]; then
  wget -nc -P "$FONT_PATH" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
  unzip "$FONT_PATH/JetBrainsMono.zip" -d "$FONT_PATH/JetBrainsMono"
  rm "$FONT_PATH/JetBrainsMono.zip"
  fc-cache -fv
fi
