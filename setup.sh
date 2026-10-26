#!/usr/bin/env bash

set -euo pipefail

if ! command -v dnf >/dev/null; then
  echo "Did not find dnf"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

sudo dnf copr enable dejan/lazygit
xargs -a "$DOTFILES_PATH/pkgs.txt" sudo dnf install
stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
