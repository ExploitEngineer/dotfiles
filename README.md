# dotfiles

Personal configuration for an Arch Linux and Hyprland desktop running the [HyDE](https://github.com/HyDE-Project/HyDE) framework.

This repository holds only the files that differ from HyDE's shipped defaults.
Anything byte-identical to upstream is left out, so what remains is the actual customisation rather than a copy of HyDE.

## System

| | |
|---|---|
| Distribution | Arch Linux (`linux-lts`) |
| Hardware | HP ZBook Studio x360 G5 |
| Compositor | Hyprland 0.56.2 |
| Framework | HyDE, Lua configuration mode |
| Shell | zsh |
| Bar | waybar |
| Launcher | rofi |
| Notifications | dunst (see [Notifications](#notifications)) |

## Layout

Packages are [GNU Stow](https://www.gnu.org/software/stow/) directories.
Each mirrors the path it targets under `$HOME`, so a package can be installed or removed on its own.

```
dotfiles/
├── hypr/       .config/hypr        hyprland.lua, hyprlock, hyprsunset, pyprland
├── desktop/    .config/waybar      bar layout, browser flags
├── terminal/   .config/tmux        tmux
├── shell/      .bashrc .profile    bash, zsh (.config/zsh), fish
├── theme/      gtk, qt, xsettings  toolkit theming
├── cli/        btop, cava, ...     fastfetch, htop
├── git/        .gitconfig          git identity and global ignore
├── xdg/        mimeapps.list       default handlers, environment.d
├── hyde/       .config/hyde        wallbash hooks (video wallpaper)
└── patches/                        fixes for HyDE-owned program files
```

Not every configured program appears here.
kitty, rofi, dunst and wlogout are configured entirely by HyDE defaults and wallbash output, so there is nothing of mine to track.

## Install

Install HyDE first.
This repository layers on top of it and does not replace it.

```sh
sudo pacman -S stow
git clone git@github.com:ExploitEngineer/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh -n     # preview the symlinks
./install.sh        # apply them
```

Install a subset instead:

```sh
./install.sh hypr shell
```

Remove the symlinks again, leaving this repository untouched:

```sh
./uninstall.sh
```

### System files this repository cannot hold

Stow only writes into `$HOME`, so three things have to be recreated by hand on a fresh machine.
All three are documented with their exact contents:

| File | Documented under |
|---|---|
| `/etc/environment` | [Graphics](#graphics) |
| `/etc/default/grub` kernel command line | [Graphics](#graphics), [Machine-specific notes](#machine-specific-notes) |
| `/etc/systemd/journald.conf.d/00-size.conf` | `SystemMaxUse=500M`, or the journal grows unbounded |

Also install `libva-nvidia-driver` and `libva-utils`, and enable `fstrim.timer`, which is off by default on Arch.

### The working copy is not stowed

`install.sh` symlinks these packages into `$HOME` with GNU stow, but on the machine this repository was built from, nothing under `~/.config` is a symlink.
Every live file is a plain copy, so edits made in place never reach the repository and have to be copied back out by hand.

That is not a theoretical problem.
Six files had silently drifted before the last sync: `btop.conf`, `cava/config`, `waybar/config.jsonc`, `hyprland.lua`, `.Xresources` and `mimeapps.list`.

Until `install.sh` is actually applied, treat this repository as a manual mirror and check for drift before trusting it:

```sh
for f in $(git ls-files | grep /); do
  live="$HOME/${f#*/}"
  [ -f "$live" ] && cmp -s "$live" "$f" || echo "drift: ${f#*/}"
done
```

## Generated files are not tracked

HyDE repaints a lot of configuration from the active wallpaper through wallbash.
Tracking that output would produce a diff on every theme change and would be overwritten on restore anyway.

Excluded for that reason: `hypr/themes/`, `waybar/theme.css`, `waybar/style.css`, `waybar/includes/`, `rofi/theme.rasi`, `dunst/dunstrc`, `kitty/theme.conf`, and the `wallbash` colour files under `qt5ct`, `qt6ct`, `Kvantum` and `vim`.
Compiled shader and zsh completion caches are excluded too.

## Machine-specific notes

Fixes for this particular laptop, kept so a future restore does not have to rediscover them.
All live in `hypr/.config/hypr/hyprland.lua`.

**Display scale.**
Hyprland's built-in default is `,preferred,auto,auto`, and `auto` resolves to scale 1.5 on this panel, reducing a 1920x1080 display to a 1280x720 logical desktop.
Scale is pinned to 1.0.
`nwg-displays` writes `monitors.lua`, but nothing in HyDE's Lua chain requires that file, so `hyprland.lua` loads it explicitly and falls back to a known-good rule if it is missing.

**Numlock.**
HyDE sets `input.numlock_by_default = true`.
On this keyboard the embedded numpad overlay rides on numlock, which turns `u i o j k l m p` into `4 5 6 1 2 3 0 *`.
It is forced off.

**Brightness keys.**
This machine never emits `XF86MonBrightnessUp` or `XF86MonBrightnessDown`, so HyDE's stock hardware bindings cannot fire.
Sweeping the function row produces only volume and mic-mute keysyms.
Brightness is bound to `SUPER + SHIFT + Up` and `SUPER + SHIFT + Down`, and to bare `F3` and `F4`, which is what `fn`+`F3` and `fn`+`F4` send while HP Action Keys mode is active.

**Fullscreen and pin.**
The Lua migration moved fullscreen from `SUPER + F` to `SUPER + F11`, and promoted pin from `SUPER + SHIFT + F` to `SUPER + F`.
`SUPER + F11` is unreachable here: with Action Keys mode on, bare F11 emits the wireless-toggle keysym, so the binding never fires and the keypress disables wifi instead.
Both are restored to their previous positions.

**Blue light filter.**
HyDE ships a `blue-light-filter` screen shader and enables `hyprsunset`, which together tint the display.
The shader is set to `disable` and hyprsunset is left at a neutral 6500K.

**Two boot changes that look sensible and are not.**
Both were tried on 2026-08-29 and both broke the machine.

`DisplayServer=wayland` in `/etc/sddm.conf.d/`.
SDDM cannot bring up a Wayland greeter here, falls back to `sddm-helper-start-x11user`, and that Xorg segfaults inside `libGLX_nvidia.so.0`.
The greeter then dies and respawns forever, which presents as being thrown back to the login screen over and over, and as a correct password being refused once `pam_faillock` counts the crashed authentications as failures.
The X11 greeter works fine; leave it alone.
The only thing the change buys is 63 MiB of VRAM from the `-noreset` Xorg that SDDM leaves resident.

`MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)` in `/etc/mkinitcpio.conf`.
The `modconf` hook then pulls in all 206 MB of `/usr/lib/firmware/nvidia`, producing a 298 MB initramfs against a normal 122 MB.
On this laptop that hangs the boot at a black screen followed by a white screen.
It is also redundant: `HOOKS` already contains `kms`, which handles KMS module loading, and `nvidia_drm.modeset=1` on the kernel command line is what Hyprland actually needs.

Known-good kernel command line:

```
GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 loglevel=7"
```

`nvidia_drm.fbdev=1` adds nothing here.
`quiet` must not be combined with `loglevel=7`, since it pins the console loglevel to 4 and whichever parses last wins.

## Video wallpapers

`mpvpaper` plays a video as the wallpaper, but on its own it needs the filename and a row of flags every time, and it knows nothing about themes.
`hyde/.config/hyde/wallbash/scripts/mpvpaper.sh` wires it into HyDE's own wallpaper selection instead.

**It needs no keybind.**
`~/.config/hyde/wallbash/always/` runs on every wallpaper and theme change, so `SUPER + SHIFT + W` and `SUPER + ALT + Left/Right` already drive it.

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

### Notes

The pointer to the current wallpaper is `$HYDE_CACHE_HOME/wall.set`, a symlink that `wallpaper.sh:77` calls `wallCur`.
Do not use `wall.awww.png` for this: it only exists for some themes, and where it does exist it is sometimes a real file rather than a symlink, so resolving it returns its own path.

`hwdec=auto-safe`, not `hwdec=nvdec`.
It resolves to nvdec on this machine, but the Quadro P1000 is Pascal and has no AV1 decoder, so a pinned `nvdec` would fail outright on an AV1 file instead of falling back to software.
Prefer H.264 or HEVC anyway, both of which are real NVDEC here, as is VP9.

`-p -a MAX` pauses playback whenever the wallpaper is covered, which on a laptop is most of the time.

Measured on a 1080p30 clip: `utilization.decoder` around 5 percent and roughly 417 MiB of VRAM.
That VRAM figure is worth remembering on a 4 GB card.

## Patches

`patches/` holds fixes for files HyDE installs and owns under `~/.local/lib/hyde`.
Those are program files rather than configuration, so they are not stow packages, and HyDE overwrites them on update.
Reapply with `patch -p1 --forward`, which is a no-op if the fix is already present.

See [patches/README.md](patches/README.md).
Three patches currently.
One restores the `SUPER + /` keybindings hint menu, which broke because Hyprland 0.56 emits invalid JSON from `hyprctl binds -j`.
The other stops every area screenshot asking for the region to be drawn twice, by restoring `grimblast`'s single `slurp` call.

## Notifications

HyDE ships both dunst and swaync and lets you pick one.
dunst is the one in the core package list at `Scripts/pkg_core.lst`; swaync is an optional extra pulled in through `Scripts/dots-groups/extra.toml`.
This machine uses dunst, and swaync is deliberately not installed.

Having both installed is actively harmful, not merely redundant.
Only one process can own the `org.freedesktop.Notifications` D-Bus name.
dunst wins it through its D-Bus activation file, so `swaync.service` fails with `Could not acquire notification name` and systemd restarts it until it hits `start-limit-hit`.

The expensive part is not the failed service.
HyDE's wallbash script `~/.local/share/wallbash/scripts/swaync.sh` ends in `swaync-client -R`, which blocks forever when no swaync daemon is listening.
That script runs on every theme reload and every wallpaper change, so each one leaks a `bash` and a `swaync-client` process that never exit.
Three pairs accumulated in twenty minutes of uptime on this machine, and the desktop got progressively slower as they piled up.

Removing the `swaync` package is **not** a durable fix, which took a HyDE update to discover.
`Scripts/dots-groups/extra.toml` includes `../dots/swaync.toml`, and that declares `pacman = [ "swaync" ]`, so `./install.sh -r` reinstalls the package and restores the wallbash script.

The fix that holds is `patches/0003-swaync-guard-daemon-running.patch`, which makes the script exit early unless a swaync daemon is actually running.
Reapply it after every HyDE update along with the others.

## Graphics

NVIDIA Quadro P1000 Mobile (GP107GLM), 4 GB, driver 580, `nvidia-580xx-dkms` from chaotic-aur.
Single GPU: there is no Intel iGPU visible to the OS on this machine, so nothing here is about hybrid graphics or PRIME offload.

This section is the whole story, so it does not have to be rediscovered or re-explained.

### The GPU was never the problem

Rendering has always been on the Quadro.
Hyprland, kitty, Brave and Xwayland all hold memory on it, Hyprland runs on the `drm` backend against the NVIDIA module, and Brave's GPU process opens `/dev/dri/renderD128`.

What was missing is **hardware video decode**.
`libva` was installed but `libva-nvidia-driver` was not, so there was no `nvidia_drv_video.so` under `/usr/lib/dri/`, and every browser and Electron app decoded video on the CPU.
That is what "the system is not using the GPU" actually meant: high CPU on video, fans, heat.
It was structurally impossible for `utilization.decoder` to leave 0.

### HyDE's environment mechanism emits nothing

`~/.local/share/hypr/lua/env.lua` sets `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME` and `GBM_BACKEND` through `hl.env()`, and `variables.lua` sets `MOZ_ENABLE_WAYLAND` and `ELECTRON_OZONE_PLATFORM_HINT` the same way.
None of them arrive.
The compiled config at `~/.local/state/hyde/hyprland.conf` contains **zero** `env =` lines, and reading `/proc/<pid>/environ` for waybar, kitty and Hyprland itself finds none of these variables set.

Do not try to fix this by editing `env.lua` or by adding `hl.env()` calls to `userprefs.lua`.
Both go through the same mechanism and both do nothing.

Two further things defeat the Hyprland-side approach even where it works.
waybar is started by `systemd --user`, not by Hyprland, so a Hyprland `env =` line would never reach it.
And SDDM starts the session through a login shell rather than the systemd user manager, so `~/.config/environment.d` alone does not reach Hyprland either.

### Where the variables actually live

Two files, because neither one covers both cases.
Only the second is in this repository; `/etc/environment` is a system file and has to be recreated by hand.

| File | In repo | Covers |
|---|---|---|
| `/etc/environment` | no | the whole session, via `session required pam_env.so` in `/etc/pam.d/system-auth`, which `/etc/pam.d/sddm` includes. Reaches Hyprland and everything it launches. |
| `~/.config/environment.d/10-nvidia-vaapi.conf` | `xdg/` | systemd user units, which is what waybar is |

Both contain the same five lines:

```sh
LIBVA_DRIVER_NAME=nvidia
NVD_BACKEND=direct
__GLX_VENDOR_LIBRARY_NAME=nvidia
MOZ_ENABLE_WAYLAND=1
ELECTRON_OZONE_PLATFORM_HINT=auto
```

`GBM_BACKEND=nvidia-drm` is deliberately **not** set.
It is no longer recommended on driver 580 and is a known cause of Firefox crashes.

### Packages

```sh
sudo pacman -S --needed libva-nvidia-driver libva-utils
```

`libva-nvidia-driver` provides `/usr/lib/dri/nvidia_drv_video.so`, which is the whole fix.
`libva-utils` provides `vainfo` and is only needed to verify.

### Browser flags

The filename matters.
`/usr/bin/brave-beta` reads `$XDG_CONFIG_HOME/brave-beta-flags.conf`, so a file named `brave-flags.conf` is silently ignored and nothing tells you.
Chrome reads `chrome-flags.conf`.
Both are in `desktop/` and both contain:

```
--ozone-platform-hint=auto
--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncodeLinuxGL,AcceleratedVideoDecodeLinuxGL
--disable-features=UseChromeOSDirectVideoDecoder
```

### Kernel command line

```
GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 loglevel=7"
```

`nvidia_drm.modeset=1` is required by Hyprland and must stay.
See [Machine-specific notes](#machine-specific-notes) for `nvidia_drm.fbdev=1`, mkinitcpio `MODULES` and the SDDM display server, all of which look like reasonable additions here and all of which break this laptop.

### Verifying

```sh
vainfo | grep -E "Driver version|VAProfileH264High|VAProfileVP9Profile0"
```

Expect `VA-API NVDEC driver [direct backend]` and a list of `VAEntrypointVLD` profiles.
If it reports a different driver or fails outright, `libva-nvidia-driver` is missing or `LIBVA_DRIVER_NAME` is not reaching the process.

Confirm the variables actually arrive somewhere that is not your shell, since a shell can inherit them by other routes:

```sh
tr '\0' '\n' < /proc/$(pgrep -x waybar)/environ | grep -iE "LIBVA|NVD_BACKEND"
```

Watch decode do real work.
`utilization.decoder` stays at 0 until a video actually plays, and VA-API drivers load lazily, so an idle check proves nothing:

```sh
watch -n1 nvidia-smi --query-gpu=utilization.gpu,utilization.decoder,memory.used --format=csv
```

In Brave, `brave://gpu` should report **Video Decode: Hardware accelerated**.

Day to day the GPU is already on the bar: `custom/gpuinfo` sits in `group/pill#left1` and its tooltip gives temperature, utilisation and clocks.
`btop` has an NVIDIA panel too, toggled with `5`.
Neither shows decode; `nvtop` does, with dedicated DEC and ENC columns.

The tooltip's `Power Usage: [N/A]/[N/A] W` is not a fault.
The P1000 Mobile does not expose `power.draw` to nvidia-smi.

## Legacy configuration files

A HyDE update moved the framework from `.conf` files to a Lua configuration chain.
`~/.config/hypr/hyprland.conf` is no longer read, which silently orphaned every file it used to source.

Nine such files were tracked here as a record of the pre-migration state: `animations.conf`, `hyprland.conf`, `keybindings.conf`, `monitors.conf`, `nvidia.conf`, `shaders.conf`, `userprefs.conf`, `windowrules.conf` and `workflows.conf`.
None of them had a live counterpart under `~/.config/hypr` any more.

They have been removed from the working tree.
The record is not lost: `git log --diff-filter=D -- 'hypr/.config/hypr/*.conf'` finds the commit that removed them, and the files can be read at the commit before it.

`nvidia.conf` is the one worth knowing about.
It held the VA-API and cursor settings, and it had been dead since the migration, which is part of why hardware video decode was never configured.
Its useful content now lives in `/etc/environment` and `~/.config/environment.d`, described under [Graphics](#graphics).

Active configuration lives in `hyprland.lua`, which loads `keybindings.lua` last so it overrides HyDE's defaults.

`keybindings.lua` restores the pre-migration keyboard layout.
Only the bindings that actually changed are listed there, 27 of them; the remaining ~80 already match HyDE's current defaults and are left alone.
Verified against the old config: no binding is missing, and the handful that still report a difference differ only in their description text, not in the command they run.

Two old commands no longer exist upstream and were remapped.
`$scrPath/dontkillsteam.sh` became `hl.dsp.window.close()`, and `wbarconfgen` became `hyde-shell waybar -n` and `-p`.
