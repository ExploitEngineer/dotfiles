# Notifications

The desktop uses [swaync](https://github.com/ErikReider/SwayNotificationCenter) for notification popups and the notification center.
One stylesheet is generated from the active HyDE theme, so every theme gets the same considered design in its own colours and shape.

## The design

- **Glass card.**
  A translucent card that Hyprland blurs behind, a soft drop shadow and a one-pixel inner highlight.
- **Accent edge.**
  A coloured edge on the left in the theme's accent, red with a glow for critical notifications.
- **Hierarchy.**
  A bold title, a dimmer message, a small timestamp, and the icon on its own tile.
- **Real controls.**
  Action buttons as pills, a gradient progress bar for volume and brightness, and a close button that turns red on hover.
- **Control center.**
  The same glass for the panel, the do-not-disturb switch, the title row and the widgets.

Text colour is pulled toward white or black on themes whose foreground is strongly saturated, for example Bad Blood, so it stays readable over a busy wallpaper.
Light themes get a more opaque card.

## Shape per theme

The card corner radius and the halo depend on the theme.
The table is in `hyde/.config/hyde/wallbash/scripts/swaync-style.sh`.

| Group | Corners | Halo | Themes |
|---|---|---|---|
| Sharp | 6px | none | 1-Bit, Vanta Black, Graphite Mono, Oxo Carbon, Lock In, Code Garden, Gruvbox Retro, Agency, CIA, FBI, AncientAliens, Pixel Dream |
| Soft | 22px | none | the three Catppuccins, Monterey Frost, BlueSky, Chisa, Oregairu, Greenify, Green Lush, Rosé Pine, Nier, Drawbridge |
| Neon | 16px | accent glow | Synth Wave, Obsidian Purple, Crimson Blue, Abyssal Wave, Scarlet Night, Bad Blood, DoomBringers, Crimson Blade, Red Stone, Soulsborne |
| Default | 16px | none | every other theme |

## How it is wired

- `hyde/.config/hyde/wallbash/always/swaync-style.dcol` runs `swaync-style.sh` on every theme and wallpaper change.
  The hook writes `~/.config/swaync/wallbash-style.css` and asks a running swaync to reload its CSS, so the change shows at once.
- `desktop/.config/swaync/user-style.css` imports that file.
  swaync loads HyDE's `theme.css` first and `user-style.css` last, so the generated design wins.
- `hyde/.config/hyde/wallbash/always/dunst.dcol` is a deliberate no-op.
  It shadows HyDE's own dunst step, which would otherwise run `killall dunst; dunst &` on every theme change and fight swaync for the notification name.
- The colours come from the shared palette in `lib/palette.py`, like every other [theme hook](theme-hooks.md).

## Switching between swaync and dunst

Only one process can own `org.freedesktop.Notifications`, and having both active is harmful, see [HyDE fixes](hyde-fixes.md).
`scripts/notification-daemon.sh` switches cleanly, per user, with no sudo:

```sh
scripts/notification-daemon.sh swaync    # masks dunst, points D-Bus activation at swaync, starts it
scripts/notification-daemon.sh dunst     # and back
scripts/notification-daemon.sh status
```

It masks the daemon you are not using, writes `~/.local/share/dbus-1/services/org.freedesktop.Notifications.service` for the one you are, and stops the other.
swaync is started through D-Bus activation on the first notification, so it needs no autostart entry.

Open the control center with `swaync-client -t -sw`, or bind it to a key.

## Limits

- Icons come from the active GTK icon theme.
  A theme whose icon set lacks an app's icon shows the notification without the icon tile.
- The blur needs Hyprland's layer rule for `swaync-notification-window` and `swaync-control-center`.
  HyDE ships it in `layer_rules.lua`.
- The stylesheet is checked in CI with GTK's own parser against all 37 themes, but not against a running swaync.

## Tuning

Edit `swaync-style.sh`, run it, and the change shows immediately.
To test one theme without touching your config:

```sh
SWAYNC_STYLE_PATH=/tmp/wb.css HYDE_THEME_DIR=~/.config/hyde/themes/Nier \
  hyde/.config/hyde/wallbash/scripts/swaync-style.sh
xvfb-run -a python3 scripts/check-gtk-css.py /tmp/wb.css
```
