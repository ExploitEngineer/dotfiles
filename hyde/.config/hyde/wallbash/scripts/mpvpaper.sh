#!/usr/bin/env bash
#
# Video wallpaper, driven by HyDE's own wallpaper selection.
#
# Runs from ~/.config/hyde/wallbash/always/mpvpaper.dcol on every wallpaper and
# theme change, so it needs no keybind of its own: SUPER+SHIFT+W and
# SUPER+ALT+Left/Right already trigger it.
#
# Usage: drop a video next to a still of the same basename in a theme's
# wallpapers directory.
#
#   ~/.config/hyde/themes/Code Garden/wallpapers/aurora.png   <- pick this
#   ~/.config/hyde/themes/Code Garden/wallpapers/aurora.mp4   <- this plays
#
# Select the still with your normal wallpaper keybind. wallbash reads its
# colours from the still, then this starts the video over the top. Select a
# wallpaper with no matching video and mpvpaper is stopped, leaving the static
# awww wallpaper. That is the whole design: the still is the poster frame and
# the source of truth for theming.

if ! source "$(which hyde-shell)"; then
    echo "[wallbash] mpvpaper :: Error: hyde-shell not found."
    exit 1
fi

pkg_installed mpvpaper || {
    print_log -sec "wallbash" -warn "mpvpaper" "not installed, skipping video wallpaper"
    exit 0
}

# $HYDE_CACHE_HOME/wall.set is the symlink to the wallpaper that was just
# applied; wallpaper.sh:77 calls it wallCur and it is the authoritative pointer.
# $HYDE_THEME_DIR/wall.set is the per-theme equivalent and covers the case where
# the cache has not been written yet.
#
# Do not use wall.awww.png for this. It only exists for some themes, and where
# it does exist it is sometimes a real file rather than a symlink, so resolving
# it gives you back its own path instead of the wallpaper's.
cache_dir="${HYDE_CACHE_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/hyde}"
theme_dir="${HYDE_THEME_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hyde/themes/$HYDE_THEME}"

still="$(readlink -f "${cache_dir}/wall.set" 2>/dev/null)"
[ -f "$still" ] || still="$(readlink -f "${theme_dir}/wall.set" 2>/dev/null)"

video=""
if [ -n "$still" ]; then
    for ext in mp4 webm mkv; do
        candidate="${still%.*}.${ext}"
        [ -f "$candidate" ] && { video="$candidate"; break; }
    done
fi

pkill -x mpvpaper 2>/dev/null

[ -n "$video" ] || {
    print_log -sec "wallbash" -stat "mpvpaper" "no video for $(basename "${still:-none}"), static wallpaper"
    exit 0
}

# -p / -a MAX pause playback whenever the wallpaper is covered, which on a
# laptop is most of the time.
#
# hwdec=auto-safe resolves to nvdec on this machine. Do not pin hwdec=nvdec:
# the Quadro P1000 is Pascal and has no AV1 decoder, so an AV1 file would fail
# outright rather than fall back to software.
mpvpaper -f -p -a MAX -o "no-audio loop hwdec=auto-safe vo=gpu profile=low-latency" '*' "$video"

print_log -sec "wallbash" -stat "mpvpaper" "playing $(basename "$video")"
