# hyde-wallbash

An SDDM (login screen) theme that recolors itself from HyDE's wallbash palette.

This directory is meant to be copied verbatim to `/usr/share/sddm/themes/hyde-wallbash/`
by `../install.sh`. It is not meant to be hand-edited in place afterward:

- `theme.conf` holds build-time fallback values only (the currently-active theme's colors
  and wallpaper at the time this was built). It is what SDDM falls back to if the live
  override file below is missing or broken. Edit it if you want a different permanent
  fallback, but a fresh `install.sh` re-run or a wallbash sync will not touch it either way.
- The real, per-login colors come from `/etc/sddm-wallbash/current.conf`, written by
  `../wallbash/scripts/sddm-wallbash.sh` every time HyDE's wallpaper/theme changes.
  `Main.qml` reads that file at startup and falls back to `theme.conf` if it can't.

## Files

- `metadata.desktop` - the SDDM theme manifest (`Theme-Id=hyde-wallbash`, `QtVersion=6`).
- `theme.conf` - baked-in fallback config, see comments inline.
- `Main.qml` - resolves colors/background/template, loads one of the five compositions.
- `components/Layout1Bit.qml`, `LayoutBadBlood.qml`, `LayoutRosePine.qml`,
  `LayoutSynthWave.qml`, `LayoutCatppuccin.qml` - the five compositions, one per mockup
  scene in `/tmp/sddm_preview/preview.html`.
- `components/Clock.qml`, `components/PowerRow.qml` - shared pieces used by all five.

## Testing before you trust it

See `../README.md` at the top of this project for the safe `--test-mode` command.
Never restart the real `sddm` service to test a theme change.
