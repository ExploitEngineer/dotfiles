#!/usr/bin/env bash
#
# sddm-wallbash.sh - keep the hyde-wallbash SDDM theme in sync with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/sddm-wallbash.dcol on every wallpaper and theme
# change (the same always/ mechanism mpvpaper.sh and chrome.sh already use), so it needs
# no keybind of its own - HyDE's existing wallpaper keybinds already trigger it.
#
# This writes into /etc/sddm-wallbash/, a directory ../../install.sh made group-writable
# for exactly this purpose (see that script's comments for why a dedicated group beats a
# sudoers NOPASSWD helper here). If that directory isn't writable yet - fresh install,
# this user hasn't logged back in since being added to the group - this degrades to a
# warning and exits 0: a broken sync must never take the wallpaper-set pipeline down with
# it, and the SDDM greeter already has a safe baked-in fallback in theme.conf either way.
#
# Reads dcol_* straight from the environment, no sourcing needed - same as wayle-theme.sh.
#
# Deliberately does NOT source hyde-shell for its print_log helper (chrome.sh's style):
# hyde-shell's own dispatcher does `case "$1" in ...` near the top, and wallbash invokes
# this script with no positional arguments at all. Under `set -u` that is an immediate
# "unbound variable" abort - inside an `if` condition or not, nounset is not suspended the
# way errexit is - so sourcing it here would kill this script before a single safety check
# ran. A plain echo is a perfectly fine log for a sync script; it is not worth that risk.

set -euo pipefail

log() { echo "[sddm-wallbash:$1] $2: $3"; }

STATE_DIR="/etc/sddm-wallbash"
STATE_FILE="${STATE_DIR}/current.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${dcol_pry1:-}" ]; then
    log warn "colors" "dcol_pry1 not set, nothing to sync yet"
    exit 0
fi

if [ ! -d "$STATE_DIR" ] || [ ! -w "$STATE_DIR" ]; then
    log warn "perms" "$STATE_DIR missing or not writable - re-run install.sh, or log out/in if you were just added to the sddm-wallbash group"
    exit 0
fi

# ---- resolve the active wallpaper, same two-step lookup mpvpaper.sh uses --------------
cache_dir="${HYDE_CACHE_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/hyde}"
theme_dir="${HYDE_THEME_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hyde/themes/${HYDE_THEME:-}}"

still="$(readlink -f "${cache_dir}/wall.set" 2>/dev/null || true)"
[ -n "$still" ] && [ -f "$still" ] || still="$(readlink -f "${theme_dir}/wall.set" 2>/dev/null || true)"

if [ -z "$still" ] || [ ! -f "$still" ]; then
    log warn "wallpaper" "could not resolve wall.set from cache or theme dir, keeping previous state"
    exit 0
fi

# ---- copy the wallpaper where the (unprivileged-at-login) greeter can read it ---------
# $HOME is mode 700 on this machine, and commonly is by default everywhere, so the sddm
# user cannot traverse into it even though everything below it is world-readable. Copying
# into /etc/sddm-wallbash/ (0755) and chmod'ing the copy 0644 sidesteps that entirely
# instead of relying on home-directory permissions nobody should have to loosen.
ext="img"
case "$still" in
    *.*) ext="${still##*.}" ;;
esac
wallpaper_dest="${STATE_DIR}/current-wallpaper.${ext}"
install -m 0644 "$still" "$wallpaper_dest"

# ---- pick the layout: deterministic hash of the theme name, same 5 buckets every time -
template=1
if command -v python3 >/dev/null 2>&1; then
    template="$(python3 "${SCRIPT_DIR}/pick_layout.py" "${HYDE_THEME:-1-Bit}" 2>/dev/null || echo 1)"
else
    log warn "template" "python3 not found, defaulting to Template 1"
fi

# ---- reduced motion: best-effort gsettings read, default false -----------------------
# This is a GNOME accessibility setting on a HyDE/Hyprland system that most likely does
# not have it configured at all, so "always false" here is an honest, safe degradation,
# not a bug - this is best-effort, same as the brief asked for. Two schema/key spellings
# are tried since GNOME has moved this setting between schemas across versions.
reduced_motion="false"
if command -v gsettings >/dev/null 2>&1; then
    rm_value="$(gsettings get org.gnome.desktop.interaction-accessibility reduce-motion 2>/dev/null || true)"
    if [ "$rm_value" != "true" ]; then
        anim_value="$(gsettings get org.gnome.desktop.a11y.interface enable-animations 2>/dev/null || true)"
        [ "$anim_value" = "false" ] && rm_value="true"
    fi
    [ "$rm_value" = "true" ] && reduced_motion="true"
fi

# ---- write atomically: a reader (the greeter, at any moment) never sees a half file ---
tmp_file="$(mktemp "${STATE_DIR}/.current.conf.XXXXXX")"
trap 'rm -f "$tmp_file"' EXIT
{
    printf 'Background=%s\n' "$wallpaper_dest"
    printf 'ColorPry1=%s\n' "${dcol_pry1}"
    printf 'ColorTxt1=%s\n' "${dcol_txt1:-FFFFFF}"
    printf 'ColorPry2=%s\n' "${dcol_pry2:-3A3A3A}"
    printf 'ColorPry3=%s\n' "${dcol_pry3:-7F7F7F}"
    printf 'ColorPry4=%s\n' "${dcol_pry4:-B3B3B3}"
    printf 'Template=%s\n' "$template"
    printf 'ReducedMotion=%s\n' "$reduced_motion"
} > "$tmp_file"
chmod 0644 "$tmp_file"
mv -f "$tmp_file" "$STATE_FILE"

log stat "sync" "wrote $STATE_FILE (theme=${HYDE_THEME:-?} template=$template reduced_motion=$reduced_motion)"
