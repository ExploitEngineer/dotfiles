# Maintaining this repository

How the working copy relates to the repository, and which files are deliberately not tracked.

## The working copy is not stowed

`install.sh` symlinks these packages into `$HOME` with GNU stow, but on the author's machine, nothing under `~/.config` is a symlink.
Every live file is a plain copy, so edits made in place never reach the repository and have to be copied back out by hand.

That is not a theoretical problem.
Six files had silently drifted before the last sync: `btop.conf`, `cava/config`, `waybar/config.jsonc`, `hyprland.lua`, `.Xresources` and `mimeapps.list`.

Until `install.sh` is actually applied, treat this repository as a manual mirror and check for drift before trusting it:

```sh
strip() { sed '/### Auto generated wallbash colors ###/,$d' "$1"; }
for f in $(git ls-files | grep / | grep -v '^patches/'); do
  live="$HOME/${f#*/}"
  [ -f "$live" ] || { echo "missing: ${f#*/}"; continue; }
  diff -q <(strip "$live") <(strip "$f") >/dev/null || echo "drift: ${f#*/}"
done
```

`strip` drops the wallbash block so a wallpaper change does not read as drift.
`patches/` is skipped because those files are deployed by `patch`, not by stow, so they have no counterpart under `$HOME`.

## Generated files are not tracked

HyDE repaints a lot of configuration from the active wallpaper through wallbash.
Tracking that output would produce a diff on every theme change and would be overwritten on restore anyway.

Excluded for that reason: `hypr/hyprlock.conf` (HyDE writes an absolute `/home/<user>` path into it on every layout change), `hypr/themes/`, `waybar/theme.css`, `waybar/style.css`, `waybar/includes/`, `rofi/theme.rasi`, `dunst/dunstrc`, `kitty/theme.conf`, and the `wallbash` colour files under `qt5ct`, `qt6ct`, `Kvantum` and `vim`.
Compiled shader and zsh completion caches are excluded too.

Two files needed more than a gitignore entry, because both looked like ordinary configuration:

`.Xresources` is gone entirely, and the `theme/` package with it.
Both of its lines, `Xcursor.theme` and `Xcursor.size`, are written by `theme.switch.sh:199-205` from the active theme, so none of it was ever hand-written configuration.
It changed on every theme switch and showed as drift each time.

`cava/config` is kept, because the first 330 lines are real configuration, but everything from `### Auto generated wallbash colors ###` down is wallbash output that `cava.sh:23` deletes and regenerates on every wallpaper change.
The tracked copy is truncated at that marker, and a `clean` filter declared in `.gitattributes` strips the block on staging so it cannot come back.
`cava.sh` re-appends the marker when it is missing, so a fresh checkout recovers on the first wallpaper set.

Git filters live in `.git/config`, which is not cloned, so `install.sh` registers this one.
Without it git treats the filter name as identity: nothing breaks, the block simply is not stripped.
