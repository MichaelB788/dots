# Fedora Dotfiles

These are my dotfiles for Fedora.

# Notes to Self

## DNF Config

Go to `/etc/dnf/dnf.conf/` and put this under `[main]`

```bash
max_parallel_downloads=10
defaultyes=True
keepcache=True
```

## Installing Codecs

This will install RPM Fusion and swap the open source codecs with the propreitary ones.

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf group upgrade multimedia
sudo dnf group upgrade core
```

## Terra Repo

Add the terra repo to install stuff like `lazygit`.

```bash
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
```
