#!/usr/bin/env bash

set -euo pipefail

DOTS_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)

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
    flatpak
    base-devel     # base development packages (make, automake, etc.)
    pacman-contrib # tools for pacman
    reflector      # ranks arch linux mirrors
    fwupd          # allows updating firmware

    # libvirt
    libvirt
    qemu-desktop
    edk2-ovmf # UEFI virtualization support
    dnsmasq
    iptables-nft

    # kpmcore
    kpmcore
    bcachefs-tools
    dosfstools
    e2fsprogs
    exfatprogs
    f2fs-tools
    fatresize
    ntfsprogs
    xfsprogs

    # fonts
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    ttf-liberation

    # gui
    firefox
    chromium
    virt-manager
    wireshark-qt

    # ark
    ark
    7zip
    unrar
    unarchiver

    # dolphin
    dolphin
    ffmpegthumbs
    kdegraphics-thumbnailers
    kio-admin
    kompare

    # kde
    filelight
    okular
    gwenview
    spectacle
    filelight
    kcalc
    kdeconnect
    partitionmanager

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
    zip
    zoxide    # smarter cd
    starship  # shell prompt
    git-delta # better git diffs
    github-cli
    wl-clipboard
    fastfetch
    tree-sitter-cli
    bash-completion

    # c/c++
    cmake
    ninja
    bear
    ccache
    valgrind
    gdb
    strace
    perf

    # rust
    rustup

    # lsp / formatters / linters
    clang
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

  sudo pacman -S --needed "${pacman_pkgs[@]}"

  rustup default stable
  rustup component add "${rust_pkgs[@]}"
}

add_user_to_groups() {
  groups=(libvirt wireshark plugdev)
  for group in "${groups[@]}"; do
    sudo groupadd -f "$group"
    sudo usermod -aG "$group" "$USER"
  done
}

enable_daemons() {
  local timers=(fstrim paccache)
  local sockets=(virtlxcd virtqemud virtstoraged virtnetworkd)
  sudo systemctl enable --now "${sockets[@]/%/.socket}"
  sudo systemctl enable --now "${timers[@]/%/.timer}"
}

stow_dots() {
  # Make backups
  local dots_to_backup=(".bashrc" ".gitconfig" ".config/kitty" ".config/nvim" ".config/lazygit")
  for dot in "${dots_to_backup[@]}"; do
    if [[ (-f "$HOME/$dot" || -d "$HOME/$dot") && ! -L "$HOME/$dot" ]]; then
      mv "$HOME/$dot" "$HOME/$dot.bak.$(date +%s)"
    fi
  done

  stow --target="$HOME" --dir="$DOTS_PATH" --dotfiles modules
}

main() {
  install_packages
  add_user_to_groups
  enable_daemons
  stow_dots
}

main
