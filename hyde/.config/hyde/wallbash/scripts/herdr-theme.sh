#!/usr/bin/env bash
#
# Keep herdr's UI colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/herdr.dcol on every wallpaper and
# theme change, so it needs no keybind of its own.
#
# herdr has no HyDE or wallbash integration, only a [theme.custom] table in
# ~/.config/herdr/config.toml. This script writes that table from the theme's
# kitty.theme, which every HyDE theme ships with literal colours, so herdr
# matches the terminal it runs in. Reading kitty.theme directly (rather than
# ~/.config/kitty/theme.conf) avoids racing the wallbash render that writes it.
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

exec python3 -I - <<'PY'
import colorsys
import os
import re
import subprocess
import sys

HOME = os.path.expanduser("~")
CONFIG_HOME = os.environ.get("XDG_CONFIG_HOME") or os.path.join(HOME, ".config")
THEME_DIR = os.environ.get("HYDE_THEME_DIR", "")
CONFIG = os.environ.get("HERDR_CONFIG_PATH") or os.path.join(CONFIG_HOME, "herdr", "config.toml")

BEGIN = "# >>> wallbash >>> managed by ~/.config/hyde/wallbash/scripts/herdr-theme.sh, do not edit"
END = "# <<< wallbash <<<"


def log(msg):
    print(f"[wallbash] herdr :: {msg}", file=sys.stderr)


def read_kitty_colors():
    for path in (
        os.path.join(THEME_DIR, "kitty.theme"),
        os.path.join(CONFIG_HOME, "kitty", "theme.conf"),
    ):
        if not os.path.isfile(path):
            continue
        colors = {}
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                m = re.match(r"^\s*(foreground|background|color\d+)\s+(#[0-9a-fA-F]{6})\b", line)
                if m:
                    colors[m.group(1)] = m.group(2).lstrip("#")
        if "background" in colors and "foreground" in colors:
            return colors
    return None


def rgb(h):
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def hexs(c):
    return "#" + "".join(f"{max(0, min(255, round(v))):02x}" for v in c)


def mix(a, b, t):
    """t=0 gives a, t=1 gives b."""
    return tuple(x + (y - x) * t for x, y in zip(a, b))


def luminance(c):
    r, g, b = (v / 255 for v in c)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def saturation(c):
    return colorsys.rgb_to_hsv(*(v / 255 for v in c))[1]


colors = read_kitty_colors()
if colors is None:
    log("no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

bg, fg = rgb(colors["background"]), rgb(colors["foreground"])


def ansi(n, fallback):
    for key in (f"color{n}", f"color{n + 8}"):
        if key in colors:
            return rgb(colors[key])
    return fallback


red = ansi(1, fg)
green = ansi(2, fg)
yellow = ansi(3, fg)
blue = ansi(4, fg)
magenta = ansi(5, fg)
cyan = ansi(6, fg)

# Surface and text ramp: the same steps Catppuccin uses between base and text,
# so it works for light themes (fg darker than bg) without a special case.
dark_bg = luminance(bg) < 0.5
tokens = {
    "panel_bg": bg,
    "surface_dim": mix(bg, (0, 0, 0), 0.20 if dark_bg else 0.05),
    "surface0": mix(bg, fg, 0.11),
    "surface1": mix(bg, fg, 0.22),
    "overlay0": mix(bg, fg, 0.45),
    "overlay1": mix(bg, fg, 0.55),
    "subtext0": mix(bg, fg, 0.78),
    "text": fg,
    "red": red,
    "green": green,
    "yellow": yellow,
    "peach": mix(red, yellow, 0.5),
    "blue": blue,
    "mauve": magenta,
    "teal": cyan,
    # Most saturated of the cool colours, so the accent stands out from the
    # greys on colourful themes and degrades to plain blue on monochrome ones.
    "accent": max((blue, magenta, cyan), key=saturation),
}

block = [BEGIN, "[theme]", "[theme.custom]"]
block += [f'{k} = "{hexs(v)}"' for k, v in tokens.items()]
block.append(END)
block_text = "\n".join(block) + "\n"

try:
    with open(CONFIG, encoding="utf-8") as fh:
        current = fh.read()
except FileNotFoundError:
    current = ""

managed = re.compile(re.escape(BEGIN) + r".*?" + re.escape(END) + r"\n?", re.S)
rest = managed.sub("", current)

if re.search(r"^\s*\[theme(\.[^\]]*)?\]", rest, re.M):
    log(f"{CONFIG} has its own [theme] table, leaving it alone")
    sys.exit(0)

rest = rest.rstrip("\n")
updated = (rest + "\n\n" if rest else "") + block_text

if updated == current:
    sys.exit(0)

os.makedirs(os.path.dirname(CONFIG), exist_ok=True)
tmp = CONFIG + ".wallbash.tmp"
with open(tmp, "w", encoding="utf-8") as fh:
    fh.write(updated)
os.replace(tmp, CONFIG)
log(f"wrote theme to {CONFIG}")

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
