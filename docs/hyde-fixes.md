# HyDE fixes and quirks

Problems found in HyDE or its interaction with this setup, and what fixed them.

## Patches

`patches/` holds fixes for files HyDE installs and owns under `~/.local/lib/hyde`.
Those are program files rather than configuration, so they are not stow packages, and HyDE overwrites them on update.
Reapply with `patch -p1 --forward`, which is a no-op if the fix is already present.

See [patches/README.md](../patches/README.md).
Three patches currently.
One restores the `SUPER + /` keybindings hint menu, which broke because Hyprland 0.56 emits invalid JSON from `hyprctl binds -j`.
The other stops every area screenshot asking for the region to be drawn twice, by restoring `grimblast`'s single `slurp` call.

## Notifications

HyDE ships both dunst and swaync and lets you pick one.
dunst is the one in the core package list at `Scripts/pkg_core.lst`; swaync is an optional extra pulled in through `Scripts/dots-groups/extra.toml`.
The ZBook uses dunst, and swaync is deliberately not installed.

Having both installed is actively harmful, not merely redundant.
Only one process can own the `org.freedesktop.Notifications` D-Bus name.
dunst wins it through its D-Bus activation file, so `swaync.service` fails with `Could not acquire notification name` and systemd restarts it until it hits `start-limit-hit`.

The expensive part is not the failed service.
HyDE's wallbash script `~/.local/share/wallbash/scripts/swaync.sh` ends in `swaync-client -R`, which blocks forever when no swaync daemon is listening.
That script runs on every theme reload and every wallpaper change, so each one leaks a `bash` and a `swaync-client` process that never exit.
Three pairs accumulated in twenty minutes of uptime on the ZBook, and the desktop got progressively slower as they piled up.

Removing the `swaync` package is **not** a durable fix, which took a HyDE update to discover.
`Scripts/dots-groups/extra.toml` includes `../dots/swaync.toml`, and that declares `pacman = [ "swaync" ]`, so `./install.sh -r` reinstalls the package and restores the wallbash script.

The fix that holds is `patches/0003-swaync-guard-daemon-running.patch`, which makes the script exit early unless a swaync daemon is actually running.
Reapply it after every HyDE update along with the others.
