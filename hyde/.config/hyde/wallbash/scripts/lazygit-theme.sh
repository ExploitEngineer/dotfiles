#!/usr/bin/env bash
#
# Keep lazygit's colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/lazygit.dcol on every wallpaper and
# theme change.
#
# lazygit reads several config files when LG_CONFIG_FILE lists them, later files
# winning. This hook owns one of them, ~/.config/lazygit/wallbash.yml, and never
# touches config.yml, so the user's own settings cannot clash with it. The zsh
# and bash configs in this repository set LG_CONFIG_FILE to
# "wallbash.yml,config.yml", which makes config.yml win on any overlap.
#
# A running lazygit keeps its old colours until it is restarted.
#
# Test without touching the real config:
#   LAZYGIT_THEME_PATH=/tmp/lg.yml HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/lazygit-theme.sh

command -v lazygit >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "lazygit"
OUT = os.environ.get("LAZYGIT_THEME_PATH") or os.path.join(
    palette.CONFIG_HOME, "lazygit", "wallbash.yml"
)

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

h = palette.hexs
theme = [
    ("activeBorderColor", [h(p.accent), "bold"]),
    ("inactiveBorderColor", [h(p.overlay0)]),
    ("searchingActiveBorderColor", [h(p.yellow), "bold"]),
    ("optionsTextColor", [h(p.blue)]),
    ("selectedLineBgColor", [h(p.surface1)]),
    ("inactiveViewSelectedLineBgColor", [h(p.surface0)]),
    ("cherryPickedCommitFgColor", [h(p.magenta)]),
    ("cherryPickedCommitBgColor", [h(p.surface1)]),
    ("markedBaseCommitFgColor", [h(p.blue)]),
    ("markedBaseCommitBgColor", [h(p.surface1)]),
    ("unstagedChangesColor", [h(p.red)]),
    ("defaultFgColor", [h(p.fg)]),
]

lines = [
    "# Written by ~/.config/hyde/wallbash/scripts/lazygit-theme.sh on every theme change.",
    "# Do not edit: put your own settings in config.yml, which takes precedence.",
    "gui:",
    "  theme:",
]
for key, vals in theme:
    lines.append(f"    {key}:")
    lines += [f"      - '{v}'" for v in vals]
text = "\n".join(lines) + "\n"

if palette.read_text(OUT) != text:
    palette.atomic_write(OUT, text)
    palette.log(TOOL, f"wrote theme to {OUT}")
PY
