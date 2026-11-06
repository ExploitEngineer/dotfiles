#!/usr/bin/env bash
#
# Keep herdr's UI colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/herdr.dcol on every wallpaper and
# theme change, so it needs no keybind of its own.
#
# herdr has no HyDE or wallbash integration, only a [theme.custom] table in
# ~/.config/herdr/config.toml. This script writes that table from the active
# theme's colours (see lib/palette.py), so herdr matches the terminal it runs in.
#
# Only the block between the two marker comments is managed. Everything else in
# config.toml is left alone. If config.toml already has a hand-written [theme]
# table outside the block, nothing is touched, because TOML forbids defining it
# twice.
#
# Test without touching the real config:
#   HERDR_CONFIG_PATH=/tmp/herdr.toml HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/herdr-theme.sh

command -v herdr >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import re
import subprocess
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "herdr"
CONFIG = os.environ.get("HERDR_CONFIG_PATH") or os.path.join(
    palette.CONFIG_HOME, "herdr", "config.toml"
)
BEGIN = "# >>> wallbash >>> managed by ~/.config/hyde/wallbash/scripts/herdr-theme.sh, do not edit"
END = "# <<< wallbash <<<"

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

tokens = {
    "panel_bg": p.bg,
    "surface_dim": p.surface_dim,
    "surface0": p.surface0,
    "surface1": p.surface1,
    "overlay0": p.overlay0,
    "overlay1": p.overlay1,
    "subtext0": p.subtext0,
    "text": p.fg,
    "red": p.red,
    "green": p.green,
    "yellow": p.yellow,
    "peach": p.peach,
    "blue": p.blue,
    "mauve": p.magenta,
    "teal": p.cyan,
    "accent": p.accent,
}

block = "\n".join(
    [BEGIN, "[theme]", "[theme.custom]"]
    + [f'{k} = "{palette.hexs(v)}"' for k, v in tokens.items()]
    + [END]
) + "\n"

current = palette.read_text(CONFIG)

if re.search(r"^\s*\[theme(\.[^\]]*)?\]", palette.strip_block(current, BEGIN, END), re.M):
    palette.log(TOOL, f"{CONFIG} has its own [theme] table, leaving it alone")
    sys.exit(0)

updated = palette.replace_block(current, BEGIN, END, block)
if updated == current:
    sys.exit(0)

palette.atomic_write(CONFIG, updated)
palette.log(TOOL, f"wrote theme to {CONFIG}")

# A running server only re-reads config.toml on request. Not running is fine,
# it picks the new theme up at launch.
if not os.environ.get("HERDR_CONFIG_PATH"):
    try:
        subprocess.run(
            ["herdr", "server", "reload-config"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except (OSError, subprocess.TimeoutExpired):
        pass
PY
