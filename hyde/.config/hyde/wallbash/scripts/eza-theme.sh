#!/usr/bin/env bash
#
# Keep eza's colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/eza.dcol on every wallpaper and
# theme change.
#
# eza reads ~/.config/eza/theme.yml on its own, so no shell wiring is needed and
# the new colours apply to the next eza you run. The hook owns that file: it
# writes it when it is missing or was written by this hook, and stands down when
# theme.yml is yours. An EZA_COLORS variable still overrides it.
#
# Test without touching the real config:
#   EZA_CONFIG_DIR=/tmp/eza HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/eza-theme.sh

command -v eza >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "eza"
OUT = os.path.join(
    os.environ.get("EZA_CONFIG_DIR") or os.path.join(palette.CONFIG_HOME, "eza"),
    "theme.yml",
)
MARKER = "# Written by ~/.config/hyde/wallbash/scripts/eza-theme.sh"

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)


def s(fg, *flags):
    parts = [f'foreground: "{palette.hexs(fg)}"'] + [f"{f}: true" for f in flags]
    return "{ " + ", ".join(parts) + " }"


sections = {
    "filekinds": {
        "normal": s(p.fg),
        "directory": s(p.blue, "is_bold"),
        "symlink": s(p.cyan),
        "pipe": s(p.yellow),
        "block_device": s(p.red),
        "char_device": s(p.yellow),
        "socket": s(p.red),
        "special": s(p.magenta),
        "executable": s(p.green, "is_bold"),
        "mount_point": s(p.blue, "is_bold", "is_underline"),
    },
    "perms": {
        "user_read": s(p.yellow),
        "user_write": s(p.red),
        "user_execute_file": s(p.green, "is_bold"),
        "user_execute_other": s(p.green, "is_bold"),
        "group_read": s(p.yellow),
        "group_write": s(p.red),
        "group_execute": s(p.green),
        "other_read": s(p.yellow),
        "other_write": s(p.red),
        "other_execute": s(p.green),
        "special_user_file": s(p.magenta),
        "special_other": s(p.magenta),
        "attribute": s(p.overlay1),
    },
    "size": {
        **{f"number_{k}": s(p.green) for k in ("byte", "kilo", "mega", "giga", "huge")},
        **{f"unit_{k}": s(p.overlay1) for k in ("byte", "kilo", "mega", "giga", "huge")},
    },
    "users": {
        "user_you": s(p.yellow, "is_bold"),
        "user_root": s(p.red, "is_bold"),
        "user_other": s(p.magenta),
        "group_yours": s(p.yellow),
        "group_root": s(p.red),
        "group_other": s(p.overlay1),
    },
    "links": {"normal": s(p.cyan), "multi_link_file": s(p.red, "is_bold")},
    "git": {
        "new": s(p.green),
        "modified": s(p.yellow),
        "deleted": s(p.red),
        "renamed": s(p.cyan),
        "typechange": s(p.magenta),
        "ignored": s(p.overlay0),
        "conflicted": s(p.red, "is_bold"),
    },
    "git_repo": {
        "branch_main": s(p.green),
        "branch_other": s(p.yellow),
        "git_clean": s(p.green),
        "git_dirty": s(p.yellow),
    },
    "file_type": {
        "image": s(p.yellow),
        "video": s(p.magenta),
        "music": s(p.cyan),
        "lossless": s(p.cyan, "is_bold"),
        "crypto": s(p.red),
        "document": s(p.fg),
        "compressed": s(p.red),
        "temp": s(p.overlay0),
        "compiled": s(p.cyan),
        "build": s(p.yellow),
        "source": s(p.green),
    },
}
singles = {
    "punctuation": s(p.overlay0),
    "date": s(p.blue),
    "inode": s(p.magenta),
    "blocks": s(p.cyan),
    "header": s(p.fg, "is_underline"),
    "octal": s(p.magenta),
    "flags": s(p.magenta),
    "symlink_path": s(p.cyan),
    "control_char": s(p.red),
    "broken_symlink": s(p.red),
    "broken_path_overlay": s(p.overlay0, "is_underline"),
}

lines = [
    f"{MARKER} on every theme change.",
    "# Do not edit: this file is replaced. Delete the line above to take it over.",
    "colourful: true",
]
for name, items in sections.items():
    lines.append(f"{name}:")
    lines += [f"  {k}: {v}" for k, v in items.items()]
lines += [f"{k}: {v}" for k, v in singles.items()]
text = "\n".join(lines) + "\n"

current = palette.read_text(OUT)
if current and MARKER not in current:
    palette.log(TOOL, f"{OUT} is not managed by this hook, leaving it alone")
    sys.exit(0)

if current != text:
    palette.atomic_write(OUT, text)
    palette.log(TOOL, f"wrote theme to {OUT}")
PY
