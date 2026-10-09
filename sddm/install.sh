#!/usr/bin/env bash
#
# install.sh - install the hyde-wallbash SDDM theme and its wallbash sync hook.
#
# Run this by hand, once, with sudo:
#     sudo ./install.sh
#
# It is safe to re-run: every step is idempotent (group/dir creation, file copies,
# the sddm.conf.d Current= patch, systemd enable all tolerate re-running with the same
# result). It never starts or restarts the real `sddm` service - see the printed
# "next step" at the end for the safe way to test this theme before trusting it at boot.
#
# What it touches, and why it needs root for some of it but not all of it:
#   - /usr/share/sddm/themes/hyde-wallbash/   (root-owned, like every other SDDM theme)
#   - /etc/sddm-wallbash/                     (root:sddm-wallbash, 2775 - see below)
#   - /usr/local/lib/sddm-wallbash/           (root-owned, the boot-time self-heal script)
#   - /etc/systemd/system/sddm-wallbash-boot.service
#   - /etc/sddm.conf.d/the_hyde_project.conf  (patched in place, backed up first)
#   - ~/.config/hyde/wallbash/{always,scripts}/   (the invoking user's own files, no sudo
#     needed for correctness - written with that user's ownership even though this whole
#     script runs as root, so the user's own wallbash tooling can edit them later without
#     fighting root-owned files in their own home directory)
#
# Privilege boundary for the live per-login state (/etc/sddm-wallbash/current.conf):
# the wallbash sync hook runs unprivileged, in the user's own session, and SDDM's theme
# directory + /etc are root-owned - so something has to bridge that gap. Two reasonable
# designs exist: a small root-helper script invoked through a `sudoers.d` NOPASSWD rule
# scoped to exactly that helper (the pattern kitty-wallbash uses on GitHub), or a
# dedicated group that owns a group-writable state directory. This installer uses the
# second: no new privilege-escalation surface is opened at every wallpaper change (no
# setuid-ish helper that runs as root on every theme switch); the one-time cost is that
# the invoking user must log out and back in (or run `newgrp sddm-wallbash`) once, after
# this script adds them to the new group, before the live sync hook can write to it.

set -euo pipefail

# ---- must run via sudo, not as a bare root login --------------------------------------
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "error: run this with sudo: sudo ./install.sh" >&2
    exit 1
fi
if [ -z "${SUDO_USER:-}" ] || [ "$SUDO_USER" = "root" ]; then
    echo "error: run this with 'sudo ./install.sh' as your normal user, not as a root login - it needs to know which account's wallbash config and group membership to set up." >&2
    exit 1
fi

TARGET_USER="$SUDO_USER"
TARGET_GROUP="$(id -gn "$TARGET_USER")"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
    echo "error: could not resolve a home directory for $TARGET_USER" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="hyde-wallbash"
THEME_DEST="/usr/share/sddm/themes/${THEME_NAME}"

echo "==> Installing SDDM theme to ${THEME_DEST}"
rm -rf "$THEME_DEST"
cp -r "${SCRIPT_DIR}/theme" "$THEME_DEST"
chown -R root:root "$THEME_DEST"
find "$THEME_DEST" -type d -exec chmod 0755 {} +
find "$THEME_DEST" -type f -exec chmod 0644 {} +

echo "==> Setting up the sddm-wallbash privilege boundary"
groupadd -f sddm-wallbash
install -d -m 2775 -o root -g sddm-wallbash /etc/sddm-wallbash
usermod -aG sddm-wallbash "$TARGET_USER"

echo "==> Installing the boot-time self-heal script (root-owned, outside the group-writable state dir)"
install -d -m 0755 -o root -g root /usr/local/lib/sddm-wallbash
install -m 0755 -o root -g root "${SCRIPT_DIR}/systemd/boot-apply.sh" /usr/local/lib/sddm-wallbash/boot-apply.sh
install -m 0644 -o root -g root "${SCRIPT_DIR}/systemd/defaults.conf" /usr/local/lib/sddm-wallbash/defaults.conf

echo "==> Seeding /etc/sddm-wallbash/current.conf if this is a fresh install"
if [ ! -s /etc/sddm-wallbash/current.conf ]; then
    install -m 0644 -o root -g sddm-wallbash "${SCRIPT_DIR}/systemd/defaults.conf" /etc/sddm-wallbash/current.conf
else
    echo "    current.conf already exists and is non-empty (real wallbash state) - leaving it alone"
fi

echo "==> Letting the greeter actually read that live state file"
# Qt 6 blocks XMLHttpRequest reads of file:// URLs by default (a sandboxing default, not
# a bug) - Main.qml's live-override read would otherwise always silently come back empty
# and the greeter would never show anything but theme.conf's baked-in fallback colors.
# GreeterEnvironment is SDDM's own built-in mechanism for this (confirmed via
# `sddm --example-config`: "[General] GreeterEnvironment=... # environment variables to be
# set"), so this gets its own small conf.d file rather than editing
# the_hyde_project.conf's [General] section in place - nothing there to lose track of, and
# nothing to back up, since install.sh owns this whole file and can just regenerate it.
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/hyde-wallbash-env.conf <<'ENVEOF'
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1
ENVEOF

echo "==> Installing systemd unit sddm-wallbash-boot.service"
install -m 0644 -o root -g root "${SCRIPT_DIR}/systemd/sddm-wallbash-boot.service" /etc/systemd/system/sddm-wallbash-boot.service
systemctl daemon-reload
systemctl enable sddm-wallbash-boot.service

echo "==> Installing the wallbash sync hook into ${TARGET_HOME}/.config/hyde/wallbash/ (owned by ${TARGET_USER}, no sudo needed for this part conceptually)"
install -D -m 0644 -o "$TARGET_USER" -g "$TARGET_GROUP" \
    "${SCRIPT_DIR}/wallbash/always/sddm-wallbash.dcol" \
    "${TARGET_HOME}/.config/hyde/wallbash/always/sddm-wallbash.dcol"
install -D -m 0755 -o "$TARGET_USER" -g "$TARGET_GROUP" \
    "${SCRIPT_DIR}/wallbash/scripts/sddm-wallbash.sh" \
    "${TARGET_HOME}/.config/hyde/wallbash/scripts/sddm-wallbash.sh"
install -D -m 0755 -o "$TARGET_USER" -g "$TARGET_GROUP" \
    "${SCRIPT_DIR}/wallbash/scripts/pick_layout.py" \
    "${TARGET_HOME}/.config/hyde/wallbash/scripts/pick_layout.py"

echo "==> Pointing SDDM at the new theme (backing up first, never overwriting an existing backup)"
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="${SDDM_CONF_DIR}/the_hyde_project.conf"
SDDM_BACKUP="${SDDM_CONF_DIR}/backup_the_hyde_project.conf"
mkdir -p "$SDDM_CONF_DIR"

if [ -f "$SDDM_CONF" ]; then
    # -s (non-empty), not -e (exists): this machine already has a 0-byte
    # backup_the_hyde_project.conf left over from somewhere, and a 0-byte "backup" is not
    # actually a backup - trusting it as one would mean the rollback instructions printed
    # below restore an empty file instead of the real previous config. An empty file gets
    # replaced with a real backup; a genuine non-empty prior backup is still left alone.
    if [ ! -s "$SDDM_BACKUP" ]; then
        cp -p "$SDDM_CONF" "$SDDM_BACKUP"
        echo "    backed up existing ${SDDM_CONF} -> ${SDDM_BACKUP}"
    else
        echo "    ${SDDM_BACKUP} already exists and is non-empty - leaving it alone, not re-backing-up"
    fi
    if grep -q '^Current=' "$SDDM_CONF"; then
        sed -i "s/^Current=.*/Current=${THEME_NAME}/" "$SDDM_CONF"
    elif grep -q '^\[Theme\]' "$SDDM_CONF"; then
        sed -i "/^\[Theme\]/a Current=${THEME_NAME}" "$SDDM_CONF"
    else
        printf '\n[Theme]\nCurrent=%s\n' "$THEME_NAME" >> "$SDDM_CONF"
    fi
else
    printf '[Theme]\nCurrent=%s\n' "$THEME_NAME" > "$SDDM_CONF"
    echo "    created ${SDDM_CONF} (none existed)"
fi

cat <<EOF

==> Done.

${TARGET_USER} was added to the sddm-wallbash group just now - that only takes effect
after logging out and back in (or running 'newgrp sddm-wallbash' in a shell you keep
using). Until then, the wallbash sync hook will log a warning and skip itself safely
rather than fail loudly; the greeter still has a correct baked-in fallback either way.

Test the new theme BEFORE touching the real sddm service or rebooting:

    sddm-greeter-qt6 --test-mode --theme ${THEME_DEST}

This script never restarts or reloads sddm.service itself - that is your call, once
you're happy with what --test-mode shows you. If something looks wrong, restore the
previous config instead of touching anything live:

    sudo cp ${SDDM_BACKUP} ${SDDM_CONF}
EOF
