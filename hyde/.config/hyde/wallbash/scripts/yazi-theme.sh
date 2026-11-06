#!/usr/bin/env bash
#
# Keep yazi's colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/yazi.dcol on every wallpaper and
# theme change.
#
# This hook owns ~/.config/yazi/theme.toml. It writes the file when it is missing
# or was written by this hook, and stands down when theme.toml is yours, because
# TOML forbids defining a table such as [mgr] twice. To keep your own theme.toml
# and still theme yazi, copy the sections you want from the generated file.
#
# A running yazi keeps its old colours until it is restarted.
#
# Test without touching the real config:
#   YAZI_CONFIG_HOME=/tmp/yazi-test HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/yazi-theme.sh

command -v yazi >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "yazi"
CONF = os.environ.get("YAZI_CONFIG_HOME") or os.path.join(palette.CONFIG_HOME, "yazi")
THEME = os.path.join(CONF, "theme.toml")

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

c = lambda col: f'"{palette.hexs(col)}"'  # noqa: E731


def style(fg=None, bg=None, extra=""):
    parts = []
    if fg is not None:
        parts.append(f"fg = {c(fg)}")
    if bg is not None:
        parts.append(f"bg = {c(bg)}")
    if extra:
        parts.append(extra)
    return "{ " + ", ".join(parts) + " }"


bold = "bold = true"
MARKER = "# Written by ~/.config/hyde/wallbash/scripts/yazi-theme.sh"
doc = f"""{MARKER} on every theme change.
# Do not edit: this file is replaced. Delete the line above to take it over.

[mgr]
cwd = {style(p.accent)}
hovered = {style(None, p.surface1)}
preview_hovered = {style(None, p.surface0)}
find_keyword = {style(p.yellow, extra=bold)}
find_position = {style(p.magenta, extra=bold)}
symlink_target = {style(p.cyan, extra="italic = true")}
marker_copied = {style(p.green, p.green)}
marker_cut = {style(p.red, p.red)}
marker_marked = {style(p.cyan, p.cyan)}
marker_selected = {style(p.yellow, p.yellow)}
count_copied = {style(p.bg, p.green)}
count_cut = {style(p.bg, p.red)}
count_selected = {style(p.bg, p.yellow)}
border_style = {style(p.overlay0)}

[tabs]
active = {style(p.bg, p.accent, bold)}
inactive = {style(p.subtext0, p.surface1)}

[mode]
normal_main = {style(p.bg, p.accent, bold)}
normal_alt = {style(p.accent, p.surface1)}
select_main = {style(p.bg, p.green, bold)}
select_alt = {style(p.green, p.surface1)}
unset_main = {style(p.bg, p.magenta, bold)}
unset_alt = {style(p.magenta, p.surface1)}

[status]
overall = {style(p.fg, p.surface_dim)}
perm_type = {style(p.blue)}
perm_read = {style(p.yellow)}
perm_write = {style(p.red)}
perm_exec = {style(p.green)}
perm_sep = {style(p.overlay0)}
progress_label = {style(p.fg, extra=bold)}
progress_normal = {style(p.blue, p.surface1)}
progress_error = {style(p.red, p.surface1)}

[input]
border = {style(p.accent)}

[pick]
border = {style(p.accent)}
active = {style(p.magenta, extra=bold)}

[confirm]
border = {style(p.accent)}
title = {style(p.accent)}

[cmp]
border = {style(p.accent)}

[tasks]
border = {style(p.accent)}
hovered = {style(p.magenta, extra="underline = true")}

[which]
mask = {style(None, p.surface_dim)}
cand = {style(p.cyan)}
rest = {style(p.overlay1)}
desc = {style(p.magenta)}
separator_style = {style(p.overlay0)}

[help]
on = {style(p.magenta)}
run = {style(p.cyan)}
desc = {style(p.overlay1)}
hovered = {style(None, p.surface1, bold)}
footer = {style(p.fg, p.surface0)}

[notify]
title_info = {style(p.green)}
title_warn = {style(p.yellow)}
title_error = {style(p.red)}

[filetype]
rules = [
    {{ url = "*/", fg = {c(p.blue)}, bold = true }},
    {{ url = "*", is = "link", fg = {c(p.cyan)} }},
    {{ url = "*", is = "exec", fg = {c(p.green)} }},
    {{ mime = "image/*", fg = {c(p.yellow)} }},
    {{ mime = "{{audio,video}}/*", fg = {c(p.magenta)} }},
    {{ mime = "application/{{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}}", fg = {c(p.red)} }},
]
"""

current = palette.read_text(THEME)
if current and MARKER not in current:
    palette.log(TOOL, f"{THEME} is not managed by this hook, leaving it alone")
    sys.exit(0)

if current != doc:
    palette.atomic_write(THEME, doc)
    palette.log(TOOL, f"wrote theme to {THEME}")
PY
