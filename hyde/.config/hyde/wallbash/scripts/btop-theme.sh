#!/usr/bin/env bash
#
# Keep btop's colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/btop.dcol on every wallpaper and
# theme change.
#
# This hook owns ~/.config/btop/themes/wallbash.theme. The btop.conf in this
# repository selects it with `color_theme = "wallbash"`, and btop falls back to
# its default theme until the hook has run once. A running btop is told to
# reload with SIGUSR2, so it repaints at once.
#
# Test without touching the real config:
#   XDG_CONFIG_HOME=/tmp/cfg HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/btop-theme.sh

command -v btop >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import subprocess
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "btop"
OUT = os.path.join(palette.CONFIG_HOME, "btop", "themes", "wallbash.theme")

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

h = palette.hexs


def ramp(c):
    """Dim, base and bright steps of one hue, for a three-stop gradient."""
    return palette.mix(c, p.bg, 0.4), c, palette.mix(c, p.fg, 0.3)


def gradient(name, stops):
    return [f'theme[{name}_{pos}]="{h(c)}"' for pos, c in zip(("start", "mid", "end"), stops)]


lines = [
    "# Written by ~/.config/hyde/wallbash/scripts/btop-theme.sh on every theme change.",
    "# Do not edit.",
    f'theme[main_bg]="{h(p.bg)}"',
    f'theme[main_fg]="{h(p.fg)}"',
    f'theme[title]="{h(p.fg)}"',
    f'theme[hi_fg]="{h(p.accent)}"',
    f'theme[selected_bg]="{h(p.surface1)}"',
    f'theme[selected_fg]="{h(p.fg)}"',
    f'theme[inactive_fg]="{h(p.overlay0)}"',
    f'theme[graph_text]="{h(p.subtext0)}"',
    f'theme[meter_bg]="{h(p.surface1)}"',
    f'theme[proc_misc]="{h(p.cyan)}"',
    f'theme[cpu_box]="{h(p.blue)}"',
    f'theme[mem_box]="{h(p.green)}"',
    f'theme[net_box]="{h(p.magenta)}"',
    f'theme[proc_box]="{h(p.cyan)}"',
    f'theme[div_line]="{h(p.overlay0)}"',
]
traffic = (p.green, p.yellow, p.red)
lines += gradient("temp", traffic)
lines += gradient("cpu", traffic)
lines += gradient("free", ramp(p.green))
lines += gradient("cached", ramp(p.cyan))
lines += gradient("available", ramp(p.yellow))
lines += gradient("used", ramp(p.red))
lines += gradient("download", ramp(p.blue))
lines += gradient("upload", ramp(p.magenta))
lines += gradient("process", traffic)
text = "\n".join(lines) + "\n"

if palette.read_text(OUT) == text:
    sys.exit(0)

palette.atomic_write(OUT, text)
palette.log(TOOL, f"wrote theme to {OUT}")

if not os.environ.get("XDG_CONFIG_HOME"):
    try:
        subprocess.run(
            ["pkill", "-USR2", "-u", str(os.getuid()), "-x", "btop"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except (OSError, subprocess.TimeoutExpired):
        pass
PY
