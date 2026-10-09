#!/usr/bin/env bash
#
# boot-apply.sh - defensive self-heal for the hyde-wallbash SDDM state file, run once by
# sddm-wallbash-boot.service before sddm.service starts.
#
# Why this exists even though the live state file already lives in persistent /etc/
# storage, not a /run tmpfs that would be wiped on reboot (unlike the volatile-state
# design this unit's shape was modeled after): if /etc/sddm-wallbash/current.conf is ever
# missing entirely - a fresh install before any wallpaper change has run the user-session
# hook, a half-written file from a crash mid-write, or someone deleting it by hand - the
# greeter's own Main.qml already falls back to its baked-in theme.conf defaults just fine.
# This unit is extra defense-in-depth, not a load-bearing requirement: it makes sure a
# *complete, valid* state file exists on disk before the greeter ever starts, instead of
# leaving that entirely to Main.qml's runtime try/catch.
#
# Deliberately installed root-owned, outside /etc/sddm-wallbash/ (which install.sh makes
# group-writable by design): a script systemd runs as root must never live somewhere an
# unprivileged group member could overwrite it.

set -euo pipefail

STATE_DIR="/etc/sddm-wallbash"
STATE_FILE="${STATE_DIR}/current.conf"
DEFAULTS_FILE="/usr/local/lib/sddm-wallbash/defaults.conf"

if [ ! -d "$STATE_DIR" ]; then
    # Normally install.sh already created this with the right group and mode; this is
    # only reached if it's missing entirely. Falls back to a plain mkdir -p (root:root
    # 0755) if the sddm-wallbash group somehow doesn't exist yet either - still safe,
    # just means the live sync hook will need install.sh re-run before it can write here.
    install -d -m 2775 -o root -g sddm-wallbash "$STATE_DIR" 2>/dev/null || mkdir -p "$STATE_DIR"
fi

if [ -s "$STATE_FILE" ]; then
    # Already has content from a real wallbash run (or a previous boot-apply) - leave it.
    exit 0
fi

if [ -f "$DEFAULTS_FILE" ]; then
    install -m 0644 "$DEFAULTS_FILE" "$STATE_FILE"
fi
