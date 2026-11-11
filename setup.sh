#!/usr/bin/env bash

set -euo pipefail

if ! command -v pacman >/dev/null; then
  echo "pacman not found"
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not root (it uses sudo where needed)"
  exit 1
fi

DOTFILES_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

PACMAN_PKGS=(
  # system
  base-devel
  pacman-contrib
  reflector    # ranks arch linux mirrors
  fwupd        # allows updating firmware
  qemu-desktop # qemu virtualization
  libvirt      # virtualization
  edk2-ovmf    # uefi support for virtual machines
  7zip         # .7z
  zip          # .zip
  unrar        # .rar
  exfatprogs   # exfat
  dosfstools   # fat family
  ntfs-3g      # ntfs

  # fonts
  ttf-jetbrains-mono-nerd
  noto-fonts
  noto-fonts-emoji
  ttf-liberation

  # gui
  firefox
  chromium
  virt-manager
  mpv

  # kde
  dolphin
  ark                      # archiving
  kio-admin                # "open as administrator" in Dolphin
  ffmpegthumbs             # video thumbnails in Dolphin
  kdegraphics-thumbnailers # pdf/image thumbnails in Dolphin
  okular                   # document viewer
  gwenview                 # image viewer
  spectacle                # screenshot captures
  filelight                # disk usage
  kcalc
  kdeconnect # device sync

  # tui
  neovim
  lazygit

  # terminal utils
  bat
  less
  man-db
  man-pages
  fd
  fzf
  ripgrep
  stow
  curl
  wget
  zoxide   # smarter cd
  starship # shell prompt
  github-cli
  wl-clipboard
  fastfetch
  tree-sitter-cli
  bash-completion

  # c/c++
  gcc
  clang
  make
  cmake
  ninja
  bear
  ccache
  valgrind
  gdb
  strace
  perf
  sdl3
  sdl3_ttf
  sdl3_image

  # rust
  rustup

  # lsp / formatters / linters
  cppcheck
  python-lsp-server
  ruff
  lua-language-server
  stylua
  shellcheck
  shfmt
  bash-language-server
)

RUST_PKGS=(rust-analyzer clippy)

# Back up existing .bashrc before stowing it
if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
  mv "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%s)"
fi

sudo pacman -Syu --needed "${PACMAN_PKGS[@]}"

rustup default stable
rustup component add "${RUST_PKGS[@]}"

sudo systemctl enable --now fstrim.timer paccache.timer

stow --target="$HOME" --dir="$DOTFILES_PATH" --dotfiles modules
