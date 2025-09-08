#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Un-stowing .config from $DOTFILES_DIR"
stow -d "$DOTFILES_DIR" -t "$HOME" -D .config
echo "Done. Note: backups created during install (if any) are in ~/.dotfiles-backup/"
