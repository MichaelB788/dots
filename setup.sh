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

install_packages() {
  local pacman_pkgs=(
    # system
    base-devel     # base development packages (make, automake, etc.)
    pacman-contrib # tools for pacman
    reflector      # ranks arch linux mirrors
    fwupd          # allows updating firmware
    qemu-desktop   # desktop virtualization core
    libvirt        # virtualization core
    edk2-ovmf      # UEFI virtualization support
    7zip           # .7z support
    zip            # .zip support
    unrar          # .rar support

    # optional dependecies for kpm core
    bcachefs-tools # BCacheFS support
    dosfstools     # FAT32 support
    e2fsprogs      # ext2/3/4 support
    exfatprogs     # exFAT support (alternative to exfat-utils)
    f2fs-tools     # F2FS support
    fatresize      # FAT resize support
    ntfsprogs      # NTFS support

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
    kcalc                    # calculator
    kdeconnect               # device sync
    partitionmanager         # disk manager

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
    zoxide    # smarter cd
    starship  # shell prompt
    git-delta # better git diffs
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

  local rust_pkgs=(rust-analyzer clippy)

  # Back up existing .bashrc before stowing it
  if [[ -f "$HOME/.bashrc" && ! -L "$HOME/.bashrc" ]]; then
    mv "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%s)"
  fi

  sudo pacman -S --needed "${pacman_pkgs[@]}"

  rustup default stable
  rustup component add "${rust_pkgs[@]}"
}

enable_services() {
  local timers=(fstrim.timer paccache.timer)
  sudo systemctl enable --now "${timers[@]}"
}

stow_dots() {
  dots_path=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)
  stow --target="$HOME" --dir="$dots_path" --dotfiles modules
}

main() {
  install_packages
  enable_services
  stow_dots
}

main
