# Video wallpapers



`mpvpaper` plays a video as the wallpaper, but on its own it needs the filename and a row of flags every time, and it knows nothing about themes.
`hyde/.config/hyde/wallbash/scripts/mpvpaper.sh` wires it into HyDE's own wallpaper selection instead.

**It needs no keybind.**
`~/.config/hyde/wallbash/always/` runs on every *global* wallpaper set, which is what all three HyDE wallpaper keybinds use, so they already drive it:

| Keybind | Command |
|---|---|
| `SUPER + ALT + Right` | `hyde-shell wallpaper -Gn` |
| `SUPER + ALT + Left` | `hyde-shell wallpaper -Gp` |
| `SUPER + SHIFT + W` | `wallpaper -GS` |

The `-G` matters.
`color.set.sh` is only called when `set_as_global` is true (`wallpaper/core.sh:73`), so a plain `hyde-shell wallpaper --next` changes the image but skips the entire colour pass and no `always/` script runs at all.
That is worth knowing before scripting wallpaper changes by hand, and it is easy to misread as the hook being broken.

**It does not run at login.**
`start_up.lua:15` restores the wallpaper without a global colour pass, so no `always/` script runs on session start and the video does not resume after a reboot until a wallpaper key is pressed once.
Verified by mtimes: Hyprland started 15:05:44 and `wall.dcol` was refreshed at 15:05:48, but `~/.config/cava/config` stayed at 15:02:03.

To use it, put a video next to a still of the same basename in a theme's wallpapers directory:

```
~/.config/hyde/themes/Code Garden/wallpapers/aurora.png   <- select this
~/.config/hyde/themes/Code Garden/wallpapers/aurora.mp4   <- this plays
```

Selecting the still is what matters.
wallbash reads its colours from the still, then the hook starts the video over the top, so theming keeps working exactly as before.
Select a wallpaper with no matching video and mpvpaper is stopped, leaving the ordinary awww wallpaper.
The still is both the poster frame and the source of truth for colours.

`.mp4`, `.webm` and `.mkv` are recognised.

## Notes

The pointer to the current wallpaper is `$HYDE_CACHE_HOME/wall.set`, a symlink that `wallpaper.sh:77` calls `wallCur`.
Do not use `wall.awww.png` for this: it only exists for some themes, and where it does exist it is sometimes a real file rather than a symlink, so resolving it returns its own path.

`hwdec=auto-safe`, not `hwdec=nvdec`.
It resolves to nvdec on the ZBook, but the Quadro P1000 is Pascal and has no AV1 decoder, so a pinned `nvdec` would fail outright on an AV1 file instead of falling back to software.
Prefer H.264 or HEVC anyway, both of which are real NVDEC here, as is VP9.

`-p -a MAX` pauses playback whenever the wallpaper is covered, which on a laptop is most of the time.

Measured on a 1080p30 clip: `utilization.decoder` around 5 percent and roughly 417 MiB of VRAM.
That VRAM figure is worth remembering on a 4 GB card.
