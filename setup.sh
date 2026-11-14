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
    pacman-contrib # tools for pacman
    reflector      # ranks arch linux mirrors
    fwupd          # allows updating firmware

    # fonts
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    ttf-liberation

    # gui
    firefox
    chromium
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

    # partitionmanager
    partitionmanager
    kpmcore
    bcachefs-tools
    dosfstools
    e2fsprogs
    exfatprogs
    f2fs-tools
    fatresize
    ntfsprogs
    xfsprogs

    # virt-manager
    virt-manager
    libvirt
    qemu-desktop
    edk2-ovmf
    dnsmasq
    iptables-nft

    # kde
    filelight
    okular
    gwenview
    spectacle
    filelight
    kcalc
    kdeconnect
    ktorrent

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
    unzip
    zoxide
    starship
    git-delta
    github-cli
    wl-clipboard
    fastfetch
    tree-sitter-cli
    bash-completion

    # devel packages
    base-devel
    autoconf-archive
    cmake
    ninja
    bear
    ccache
    valgrind
    gdb
    strace
    perf
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

install_extra_devel_tools() {
  # install vcpkg
  local vcpkg_path="$HOME/vcpkg"
  if [[ ! -d "$vcpkg_path" ]]; then
    git clone https://github.com/microsoft/vcpkg.git "$vcpkg_path"
  fi
  (cd "$vcpkg_path" && ./bootstrap-vcpkg.sh -disableMetrics)
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
  install_extra_devel_tools
  add_user_to_groups
  enable_daemons
  stow_dots
}

main
