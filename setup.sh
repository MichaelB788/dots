#!/usr/bin/env bash

set -euo pipefail

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

# Download packages
xargs -a "$DOTFILES_PATH/pkgs.txt" sudo dnf install -y

# Stow dotfiles
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules

# Download wallpapers
WALLPAPERS=(
    "https://w.wallhaven.cc/full/gp/wallhaven-gpj7mq.jpg"
    "https://w.wallhaven.cc/full/je/wallhaven-jevqpy.png"
    "https://w.wallhaven.cc/full/5w/wallhaven-5wmm57.jpg"
)
wget -nc -P "$HOME/Pictures" "${WALLPAPERS[@]}"

# Download JetBrainsMono nerd font
FONT_PATH="$HOME/.local/share/fonts"
if [ ! -d "$FONT_PATH/JetBrainsMono" ]; then
  wget -nc -P "$FONT_PATH" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
  unzip "$FONT_PATH/JetBrainsMono.zip" -d "$FONT_PATH/JetBrainsMono"
  rm "$FONT_PATH/JetBrainsMono.zip"
  fc-cache -fv
fi
