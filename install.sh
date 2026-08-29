#!/usr/bin/env bash
#
# Symlink the selected stow packages into $HOME.
#
# Usage:
#   ./install.sh                 install every package
#   ./install.sh hypr shell      install only the named packages
#   ./install.sh -n              dry run, show what would change
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(hypr desktop terminal shell theme cli git xdg hyde)

STOW_FLAGS=(--target "$HOME" --dir "$REPO")
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; STOW_FLAGS+=(--no --verbose); shift;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    -*) echo "unknown flag: $1" >&2; exit 1;;
    *) break;;
  esac
done

[ $# -gt 0 ] && PACKAGES=("$@")

command -v stow >/dev/null 2>&1 || {
  echo "error: GNU stow is not installed. Run: sudo pacman -S stow" >&2
  exit 1
}

for pkg in "${PACKAGES[@]}"; do
  [ -d "$REPO/$pkg" ] || { echo "skip: no such package '$pkg'"; continue; }
  echo ":: stowing $pkg"
  stow "${STOW_FLAGS[@]}" --restow "$pkg"
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo
  echo "Dry run only. Nothing was changed."
else
  echo
  echo "Done. Reload Hyprland with: hyprctl reload"
fi
