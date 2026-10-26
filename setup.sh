#!/usr/bin/env bash

set -euo pipefail

if ! command -v dnf >/dev/null; then
  echo "Did not find dnf"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo -y
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf group upgrade multimedia -y
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
sudo dnf group upgrade core -y
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

xargs -a "$DOTFILES_PATH/pkgs.txt" sudo dnf install -y
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
