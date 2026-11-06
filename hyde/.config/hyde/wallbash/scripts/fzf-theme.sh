#!/usr/bin/env bash
#
# Keep fzf's colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/fzf.dcol on every wallpaper and
# theme change.
#
# This hook owns ~/.config/fzf/wallbash.opts, a file of fzf options. The
# wallbash-env.sh snippet in this repository points FZF_DEFAULT_OPTS_FILE at it
# when that variable is not already set, so fzf, fzf-tab and every script that
# calls fzf pick it up. Your own FZF_DEFAULT_OPTS still applies on top.
#
# New fzf processes use the new colours straight away; no restart is needed.
#
# Test without touching the real config:
#   FZF_THEME_PATH=/tmp/fzf.opts HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/fzf-theme.sh

command -v fzf >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "fzf"
OUT = os.environ.get("FZF_THEME_PATH") or os.path.join(
    palette.CONFIG_HOME, "fzf", "wallbash.opts"
)

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

h = palette.hexs
colors = {
    "fg": h(p.fg),
    "bg": "-1",  # keep the terminal background
    "hl": h(p.accent),
    "fg+": h(p.fg),
    "bg+": h(p.surface1),
    "hl+": h(p.accent),
    "info": h(p.yellow),
    "border": h(p.overlay0),
    "separator": h(p.overlay0),
    "scrollbar": h(p.overlay0),
    "label": h(p.subtext0),
    "prompt": h(p.accent),
    "pointer": h(p.magenta),
    "marker": h(p.green),
    "spinner": h(p.magenta),
    "header": h(p.cyan),
    "gutter": "-1",
}
text = (
    "# Written by ~/.config/hyde/wallbash/scripts/fzf-theme.sh on every theme change.\n"
    "# Do not edit: put your own options in FZF_DEFAULT_OPTS, which applies on top.\n"
    "--color=" + ",".join(f"{k}:{v}" for k, v in colors.items()) + "\n"
)

if palette.read_text(OUT) != text:
    palette.atomic_write(OUT, text)
    palette.log(TOOL, f"wrote theme to {OUT}")
PY
