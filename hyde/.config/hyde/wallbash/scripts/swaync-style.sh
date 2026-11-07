#!/usr/bin/env bash
#
# Style swaync's notification popups and control center from the active HyDE
# theme.
#
# Runs from ~/.config/hyde/wallbash/always/swaync-style.dcol on every wallpaper
# and theme change. HyDE's own swaync step keeps writing theme.css; this hook
# owns ~/.config/swaync/wallbash-style.css, which user-style.css imports last,
# so it wins. It is a design, not a recolour: depth (blur from Hyprland, soft
# shadow, an inner highlight), an accent edge, and a per-theme shape.
#
# A running swaync is told to reload its CSS, so the change shows at once.
#
# Test without touching the real config:
#   SWAYNC_STYLE_PATH=/tmp/wb.css HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
#     ~/.config/hyde/wallbash/scripts/swaync-style.sh

command -v swaync >/dev/null 2>&1 || exit 0

exec python3 -I - "$(dirname "$(readlink -f "$0")")" <<'PY'
import os
import subprocess
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(sys.argv[1], "lib"))
import palette  # noqa: E402

TOOL = "swaync"
OUT = os.environ.get("SWAYNC_STYLE_PATH") or os.path.join(
    palette.CONFIG_HOME, "swaync", "wallbash-style.css"
)

p = palette.load()
if p is None:
    palette.log(TOOL, "no kitty.theme or kitty theme.conf with background and foreground, skipping")
    sys.exit(0)

theme = os.path.basename(os.environ.get("HYDE_THEME_DIR", "").rstrip("/"))

# Shape per theme. radius is the card corner radius in px; glow is the strength
# of a coloured halo around the card (0 to 1), kept for the neon-leaning themes.
SHARP = {"1-Bit", "Vanta Black", "Graphite Mono", "Oxo Carbon", "Lock In", "Code Garden",
         "Gruvbox Retro", "Agency", "CIA", "FBI", "AncientAliens", "Pixel Dream"}
SOFT = {"Catppuccin Latte", "Catppuccin-Macchiato", "Catppuccin Mocha", "Monterey Frost", "BlueSky",
        "Chisa", "Oregairu", "Greenify", "Green Lush", "Rosé Pine", "Nier", "Drawbridge"}
NEON = {"Synth Wave", "Obsidian-Purple", "Crimson-Blue", "Abyssal-Wave", "Scarlet Night",
        "Bad Blood", "DoomBringers", "Crimson Blade", "Red Stone", "Soulsborne"}
radius = 6 if theme in SHARP else 22 if theme in SOFT else 16
glow = 0.55 if theme in NEON else 0.0
light = not p.dark


def rgba(c, a):
    r, g, b = (round(max(0, min(255, v))) for v in c)
    return f"rgba({r}, {g}, {b}, {a})"


h = palette.hexs
black = (0, 0, 0)
card = palette.mix(p.bg, p.fg, 0.07)
# Some themes use a saturated foreground (Bad Blood is pure red). Text in that
# colour is hard to read on a busy wallpaper, so pull it toward white or black.
text = p.fg if palette.saturation(p.fg) < 0.45 else palette.mix(p.fg, black if light else (255, 255, 255), 0.55)
shadow = rgba(black, 0.20 if light else 0.50)
hair = rgba(p.fg, 0.10)
shine = rgba(p.fg, 0.07 if not light else 0.55)
accent2 = palette.mix(p.accent, p.magenta if p.accent != p.magenta else p.cyan, 0.45)
halo = f", 0 0 22px {rgba(p.accent, glow * 0.55)}" if glow else ""
chalo = f", 0 0 24px {rgba(p.red, 0.45)}"

css = f"""/* Written by ~/.config/hyde/wallbash/scripts/swaync-style.sh on every theme change. Do not edit. */
@define-color wb-card {rgba(card, 0.93 if light else 0.88)};
@define-color wb-card-solid {h(card)};
@define-color wb-text {h(text)};
@define-color wb-dim {h(palette.mix(text, p.bg, 0.30))};
@define-color wb-faint {h(palette.mix(text, p.bg, 0.50))};
@define-color wb-accent {h(p.accent)};
@define-color wb-accent2 {h(accent2)};
@define-color wb-red {h(p.red)};
@define-color wb-surface {h(p.surface1)};

* {{ font-family: "Inter", "SF Pro Display", "Noto Sans", sans-serif; }}

.notification-row, .notification-row:focus, .notification-row:hover {{
  background: transparent;
  outline: none;
}}
.notification-row .notification-background {{
  padding: 8px 14px;
}}

.notification-row .notification-background .notification {{
  background: @wb-card;
  color: @wb-text;
  opacity: 1;
  border: 1px solid {hair};
  border-radius: {radius}px;
  padding: 4px;
  box-shadow: inset 3px 0 0 @wb-accent, inset 0 1px 0 {shine}, 0 10px 28px {shadow}{halo};
  transition: background 150ms ease-in-out, box-shadow 150ms ease-in-out;
}}
.notification-row .notification-background .notification.critical {{
  border-color: {rgba(p.red, 0.45)};
  box-shadow: inset 3px 0 0 @wb-red, inset 0 1px 0 {shine}, 0 10px 28px {shadow}{chalo};
}}
.notification-row .notification-background .notification:hover {{
  background: alpha(@wb-card-solid, 0.92);
}}

.notification-row .notification-background .notification .notification-default-action .notification-content {{
  padding: 10px 12px;
}}

.notification-row .notification-background .notification .notification-default-action .notification-content .image {{
  min-width: 48px;
  min-height: 48px;
  margin-right: 14px;
  padding: 7px;
  border-radius: {max(radius - 6, 4)}px;
  background: alpha(@wb-accent, 0.14);
}}

.notification-row .notification-background .notification .notification-default-action .notification-content .text-box .summary {{
  font-size: 15px;
  font-weight: 600;
  color: @wb-text;
  background: transparent;
  text-shadow: none;
}}
.notification-row .notification-background .notification .notification-default-action .notification-content .text-box .time {{
  font-size: 11px;
  color: @wb-faint;
  margin-right: 30px;
}}
.notification-row .notification-background .notification .notification-default-action .notification-content .text-box .body {{
  font-size: 13px;
  color: @wb-dim;
  margin-top: 2px;
}}

progressbar trough {{
  min-height: 6px;
  border-radius: 99px;
  background: alpha(@wb-text, 0.12);
  border: none;
}}
progressbar progress {{
  min-height: 6px;
  border-radius: 99px;
  background-image: linear-gradient(to right, @wb-accent, @wb-accent2);
  border: none;
}}

.notification-row .notification-background .close-button {{
  margin: 10px 14px 0 0;
  padding: 0;
  min-width: 22px;
  min-height: 22px;
  border-radius: 99px;
  background: alpha(@wb-text, 0.10);
  color: @wb-dim;
  border: none;
  box-shadow: none;
  text-shadow: none;
}}
.notification-row .notification-background .close-button:hover {{
  background: alpha(@wb-red, 0.85);
  color: @wb-text;
}}

.notification-row .notification-background .notification .notification-action {{
  border-top: 1px solid {hair};
  margin: 0;
  padding: 6px 8px 8px;
}}
.notification-row .notification-background .notification .notification-action button {{
  margin: 2px 4px;
  padding: 6px 12px;
  border-radius: 99px;
  border: none;
  background: alpha(@wb-accent, 0.16);
  color: @wb-text;
  box-shadow: none;
  text-shadow: none;
}}
.notification-row .notification-background .notification .notification-action button:hover {{
  background: alpha(@wb-accent, 0.32);
}}

/* Control center */
.control-center {{
  background: @wb-card;
  color: @wb-text;
  opacity: 1;
  border: 1px solid {hair};
  border-radius: {radius + 4}px;
  box-shadow: inset 0 1px 0 {shine}, 0 14px 36px {shadow}{halo};
}}
.control-center viewport, .control-center list, .control-center row, .control-center .notification-group,
.control-center .control-center-list, .control-center .control-center-list-placeholder {{
  background: transparent;
  border: none;
  box-shadow: none;
}}
.control-center .widget-title {{
  margin: 14px 16px 6px;
  font-size: 17px;
  font-weight: 700;
  color: @wb-text;
}}
.control-center .widget-title button {{
  border-radius: 99px;
  border: none;
  padding: 5px 14px;
  background: alpha(@wb-accent, 0.16);
  color: @wb-text;
  box-shadow: none;
}}
.control-center .widget-title button:hover {{ background: alpha(@wb-accent, 0.32); }}
.control-center .widget-dnd {{
  margin: 6px 16px;
  font-size: 13px;
  color: @wb-dim;
}}
.control-center .widget-dnd switch {{
  border-radius: 99px;
  background: alpha(@wb-text, 0.14);
  border: none;
}}
.control-center .widget-dnd switch:checked {{ background: @wb-accent; }}
.control-center .widget-dnd switch slider {{ border-radius: 99px; background: @wb-text; }}
.control-center .widget-mpris,
.control-center .widget-volume,
.control-center .widget-backlight,
.control-center .widget-buttons-grid {{
  margin: 6px 14px;
  padding: 8px;
  border-radius: {max(radius - 2, 4)}px;
  background: alpha(@wb-text, 0.06);
  border: 1px solid {hair};
  color: @wb-text;
}}
.control-center .widget-buttons-grid > flowbox > flowboxchild > button {{
  border-radius: {max(radius - 4, 4)}px;
  border: none;
  background: alpha(@wb-text, 0.08);
  color: @wb-text;
  box-shadow: none;
}}
.control-center .widget-buttons-grid > flowbox > flowboxchild > button:checked {{ background: @wb-accent; color: {h(p.bg)}; }}
.control-center scale trough {{ min-height: 6px; border-radius: 99px; background: alpha(@wb-text, 0.14); }}
.control-center scale highlight {{ border-radius: 99px; background-image: linear-gradient(to right, @wb-accent, @wb-accent2); }}
.control-center scale slider {{ min-width: 16px; min-height: 16px; border-radius: 99px; background: @wb-text; border: none; }}
"""

if palette.read_text(OUT) == css:
    sys.exit(0)

palette.atomic_write(OUT, css)
palette.log(TOOL, f"wrote style to {OUT}")

if not os.environ.get("SWAYNC_STYLE_PATH"):
    try:
        subprocess.run(["pgrep", "-x", "swaync"], check=True, stdout=subprocess.DEVNULL, timeout=5)
        subprocess.run(["swaync-client", "--reload-css", "--skip-wait"], stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL, timeout=5)
    except (OSError, subprocess.SubprocessError):
        pass
PY
