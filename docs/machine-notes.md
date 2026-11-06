# Machine-specific notes

Fixes for the laptop this repository was built on, plus the history of the Hyprland configuration migration.
They are kept so a future restore does not have to rediscover them.

The fixes below all live in `hypr/.config/hypr/hyprland.lua`.

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

## Legacy configuration files

A HyDE update moved the framework from `.conf` files to a Lua configuration chain.
`~/.config/hypr/hyprland.conf` is no longer read, which silently orphaned every file it used to source.

Nine such files were tracked here as a record of the pre-migration state: `animations.conf`, `hyprland.conf`, `keybindings.conf`, `monitors.conf`, `nvidia.conf`, `shaders.conf`, `userprefs.conf`, `windowrules.conf` and `workflows.conf`.
None of them had a live counterpart under `~/.config/hypr` any more.

They have been removed from the working tree.
The record is not lost: `git log --diff-filter=D -- 'hypr/.config/hypr/*.conf'` finds the commit that removed them, and the files can be read at the commit before it.

`nvidia.conf` is the one worth knowing about.
It held the VA-API and cursor settings, and it had been dead since the migration, which is part of why hardware video decode was never configured.
Its useful content now lives in `/etc/environment` and `~/.config/environment.d`, described under [Graphics](graphics.md).

Active configuration lives in `hyprland.lua`, which loads `keybindings.lua` last so it overrides HyDE's defaults.

`keybindings.lua` restores the pre-migration keyboard layout.
Only the bindings that actually changed are listed there, 27 of them; the remaining ~80 already match HyDE's current defaults and are left alone.
Verified against the old config: no binding is missing, and the handful that still report a difference differ only in their description text, not in the command they run.

Two old commands no longer exist upstream and were remapped.
`$scrPath/dontkillsteam.sh` became `hl.dsp.window.close()`, and `wbarconfgen` became `hyde-shell waybar -n` and `-p`.
