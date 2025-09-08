#!/usr/bin/env bash
set -euo pipefail

# 1
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 2
PKG_ROOT="$DOTFILES_DIR/.config"
# 3
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"
# 4
echo "dotfiles: $DOTFILES_DIR"
# 5
if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow not found."
  if command -v pacman >/dev/null 2>&1; then
    read -rp "Install stow via sudo pacman -S stow ? [y/N] " ans
    if [[ "${ans,,}" == "y" ]]; then
      sudo pacman -S --noconfirm stow
    else
      echo "Please install 'stow' and re-run this script."
      exit 1
    fi
  else
    echo "Please install 'stow' (e.g. on Arch: sudo pacman -S stow) and re-run."
    exit 1
  fi
fi
# 6
mkdir -p "$BACKUP_DIR"
echo "Backups will be saved to: $BACKUP_DIR"
# 7
if [ "$#" -eq 0 ]; then
  echo "Stowing all .config -> \$HOME (default)"
  # 8
  for d in "$PKG_ROOT"/*; do
    name="$(basename "$d")"
    target="$HOME/.config/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mkdir -p "$BACKUP_DIR/.config"
      echo "Moving existing $target -> $BACKUP_DIR/.config/"
      mv "$target" "$BACKUP_DIR/.config/"
    fi
  done
  # 9
  stow -d "$DOTFILES_DIR" -t "$HOME" .config
else
  # 10
  echo "Stowing selected packages into ~/.config: $*"
  for name in "$@"; do
    if [ ! -d "$PKG_ROOT/$name" ]; then
      echo "Package not found: $name (checked $PKG_ROOT/$name). Skipping."
      continue
    fi
    target="$HOME/.config/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mkdir -p "$BACKUP_DIR/.config"
      echo "Moving existing $target -> $BACKUP_DIR/.config/"
      mv "$target" "$BACKUP_DIR/.config/"
    fi
  done
  # 11
  stow -d "$PKG_ROOT" -t "$HOME/.config" "$@"
fi

echo "Done — stowed. Backups at: $BACKUP_DIR"
