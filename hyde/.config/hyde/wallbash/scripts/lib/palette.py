"""Shared colour palette for the wallbash theme hooks.

Every hook (herdr, lazygit, tmux, starship, ...) needs the same thing: the
active HyDE theme's colours, turned into a handful of named roles. This module
is that one place, so a hook is only the part that writes its own tool's config.

Source of colours
-----------------
The theme's own kitty.theme. Every HyDE theme ships one with literal values,
and reading it directly avoids racing the wallbash render that writes
~/.config/kitty/theme.conf. That file is the fallback.

Usage from a hook (python3 -I, so extend sys.path explicitly):

    import os, sys
    sys.dont_write_bytecode = True
    sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
    import palette
    p = palette.load()
    if p is None:
        sys.exit(0)
    print(palette.hexs(p.accent))
"""

import colorsys
import os
import re
import sys

HOME = os.path.expanduser("~")
CONFIG_HOME = os.environ.get("XDG_CONFIG_HOME") or os.path.join(HOME, ".config")


def log(tool, msg):
    print(f"[wallbash] {tool} :: {msg}", file=sys.stderr)


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))


def hexs(c, hash_prefix=True):
    s = "".join(f"{max(0, min(255, round(v))):02x}" for v in c)
    return "#" + s if hash_prefix else s


def mix(a, b, t):
    """t=0 gives a, t=1 gives b."""
    return tuple(x + (y - x) * t for x, y in zip(a, b))


def luminance(c):
    r, g, b = (v / 255 for v in c)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def saturation(c):
    return colorsys.rgb_to_hsv(*(v / 255 for v in c))[1]


def _read_kitty():
    theme_dir = os.environ.get("HYDE_THEME_DIR", "")
    for path in (
        os.path.join(theme_dir, "kitty.theme"),
        os.path.join(CONFIG_HOME, "kitty", "theme.conf"),
    ):
        if not os.path.isfile(path):
            continue
        colors = {}
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                m = re.match(
                    r"^\s*(foreground|background|selection_background|color\d+)\s+(#[0-9a-fA-F]{6})\b",
                    line,
                )
                if m:
                    colors[m.group(1)] = m.group(2)
        if "background" in colors and "foreground" in colors:
            return colors
    return None


class Palette:
    """Named colour roles, all as (r, g, b) tuples of 0-255 floats."""

    def __init__(self, colors):
        self.bg = rgb(colors["background"])
        self.fg = rgb(colors["foreground"])
        self.dark = luminance(self.bg) < 0.5

        def ansi(n, fallback):
            for key in (f"color{n}", f"color{n + 8}"):
                if key in colors:
                    return rgb(colors[key])
            return fallback

        self.red = ansi(1, self.fg)
        self.green = ansi(2, self.fg)
        self.yellow = ansi(3, self.fg)
        self.blue = ansi(4, self.fg)
        self.magenta = ansi(5, self.fg)
        self.cyan = ansi(6, self.fg)
        self.peach = mix(self.red, self.yellow, 0.5)

        # Most saturated of the cool colours, so the accent stands out from the
        # greys on colourful themes and degrades to plain blue on monochrome ones.
        self.accent = max((self.blue, self.magenta, self.cyan), key=saturation)

        # Surface and text ramp: the same steps Catppuccin uses between base and
        # text, so it works for light themes (fg darker than bg) as well.
        self.surface_dim = mix(self.bg, (0, 0, 0), 0.20 if self.dark else 0.05)
        self.surface0 = self.tone(0.11)
        self.surface1 = self.tone(0.22)
        self.overlay0 = self.tone(0.45)
        self.overlay1 = self.tone(0.55)
        self.subtext0 = self.tone(0.78)

    def tone(self, t):
        """A grey between the background (t=0) and the foreground (t=1)."""
        return mix(self.bg, self.fg, t)


def load():
    """The active theme's palette, or None when no usable kitty theme exists."""
    colors = _read_kitty()
    return Palette(colors) if colors else None


def atomic_write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".wallbash.tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write(text)
    os.replace(tmp, path)


def read_text(path):
    try:
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    except FileNotFoundError:
        return ""


def replace_block(text, begin, end, block):
    """Return text with the begin..end region replaced by block, or with block
    appended when the markers are absent. The markers are part of block."""
    pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
    if pattern.search(text):
        return pattern.sub(lambda _m: block, text, count=1)
    return (text.rstrip("\n") + "\n\n" if text.strip() else "") + block


def strip_block(text, begin, end):
    pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
    return pattern.sub("", text)
