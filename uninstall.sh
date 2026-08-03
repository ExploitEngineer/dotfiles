#!/usr/bin/env bash
#
# Remove the symlinks created by install.sh. Your files stay in this repo.
#
# Usage:
#   ./uninstall.sh               remove every package
#   ./uninstall.sh hypr shell    remove only the named packages
#   ./uninstall.sh -n            dry run, show what would change
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(hypr desktop terminal shell theme cli git xdg bin)

STOW_FLAGS=(--target "$HOME" --dir "$REPO")

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) STOW_FLAGS+=(--no --verbose); shift;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    -*) echo "unknown flag: $1" >&2; exit 1;;
    *) break;;
  esac
done

[ $# -gt 0 ] && PACKAGES=("$@")

command -v stow >/dev/null 2>&1 || {
  echo "error: GNU stow is not installed." >&2
  exit 1
}

for pkg in "${PACKAGES[@]}"; do
  [ -d "$REPO/$pkg" ] || { echo "skip: no such package '$pkg'"; continue; }
  echo ":: unstowing $pkg"
  stow "${STOW_FLAGS[@]}" --delete "$pkg"
done
