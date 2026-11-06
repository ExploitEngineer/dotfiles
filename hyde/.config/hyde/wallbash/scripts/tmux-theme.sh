#!/usr/bin/env bash
#
# Keep tmux's colours in step with the active HyDE theme.
#
# Runs from ~/.config/hyde/wallbash/always/tmux.dcol on every wallpaper and
# theme change.
#
# This hook owns ~/.config/tmux/wallbash.conf and never touches tmux.conf. The
# tmux.conf in this repository loads it with `source-file -q`, and the hook
# re-sources it into any running server, so open sessions repaint at once.
# Only colours are set here, never layout: status contents stay yours.
#
# Test without touching the real config or a live server:
#   TMUX_THEME_PATH=/tmp/tmux-wb.conf TMUX_TMPDIR=/tmp/tmux-test \
#     HYDE_THEME_DIR=~/.config/hyde/themes/Nier ~/.config/hyde/wallbash/scripts/tmux-theme.sh

command -v tmux >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import subprocess
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "tmux"
OUT = os.environ.get("TMUX_THEME_PATH") or os.path.join(
    palette.CONFIG_HOME, "tmux", "wallbash.conf"
)

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

h = palette.hexs
settings = [
    ("set -g", "status-style", f"bg={h(p.surface_dim)},fg={h(p.subtext0)}"),
    ("setw -g", "window-status-style", f"fg={h(p.overlay1)}"),
    ("setw -g", "window-status-current-style", f"fg={h(p.accent)},bold"),
    ("setw -g", "window-status-activity-style", f"fg={h(p.yellow)}"),
    ("setw -g", "window-status-bell-style", f"fg={h(p.red)}"),
    ("set -g", "pane-border-style", f"fg={h(p.overlay0)}"),
    ("set -g", "pane-active-border-style", f"fg={h(p.accent)}"),
    ("set -g", "message-style", f"bg={h(p.surface1)},fg={h(p.fg)}"),
    ("set -g", "message-command-style", f"bg={h(p.surface1)},fg={h(p.yellow)}"),
    ("setw -g", "mode-style", f"bg={h(p.surface1)},fg={h(p.fg)}"),
    ("setw -g", "clock-mode-colour", h(p.accent)),
    ("set -g", "display-panes-colour", h(p.overlay1)),
    ("set -g", "display-panes-active-colour", h(p.accent)),
]

lines = [
    "# Written by ~/.config/hyde/wallbash/scripts/tmux-theme.sh on every theme change.",
    "# Do not edit: put your own settings in tmux.conf, after the source-file line.",
]
lines += [f'{cmd} {opt} "{val}"' for cmd, opt, val in settings]
text = "\n".join(lines) + "\n"

if palette.read_text(OUT) == text:
    sys.exit(0)

palette.atomic_write(OUT, text)
palette.log(TOOL, f"wrote theme to {OUT}")

# Repaint running sessions. No server is the normal case and is not an error.
try:
    subprocess.run(
        ["tmux", "source-file", OUT],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        timeout=5,
    )
except (OSError, subprocess.TimeoutExpired):
    pass
PY
