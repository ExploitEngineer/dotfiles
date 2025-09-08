#!/usr/bin/env bash
set -euo pipefail

# 1
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 2
SRC="$DOTFILES_DIR/.config/"
# 3
DEST="$HOME/.config/"
# 4
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"
# 5
echo "Backing up existing configs to: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
# 6
rsync -avh --no-perms --progress --backup --backup-dir="$BACKUP_DIR" --exclude='.git' "$SRC" "$DEST"
# 7
echo "Copy complete. Backups (if any) are at: $BACKUP_DIR"
echo "You may need to restart or relaunch relevant applications."
