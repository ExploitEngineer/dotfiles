# dotfiles

Personal configuration for an Arch Linux and Hyprland desktop running the [HyDE](https://github.com/HyDE-Project/HyDE) framework.

This repository holds only the files that differ from HyDE's shipped defaults.
Anything byte-identical to upstream is left out, so what remains is the actual customisation rather than a copy of HyDE.

## System

| | |
|---|---|
| Distribution | Arch Linux (`linux-lts`) |
| Hardware | HP ZBook Studio x360 G5 |
| Compositor | Hyprland 0.56.0 |
| Framework | HyDE, Lua configuration mode |
| Shell | zsh |
| Bar | waybar |
| Launcher | rofi |
| Notifications | dunst |

## Layout

Packages are [GNU Stow](https://www.gnu.org/software/stow/) directories.
Each mirrors the path it targets under `$HOME`, so a package can be installed or removed on its own.

```
dotfiles/
├── hypr/       .config/hypr        hyprland.lua, hyprlock, hyprsunset, pyprland
├── desktop/    .config/waybar      bar layout and user styling
├── terminal/   .config/tmux        tmux
├── shell/      .bashrc .profile    bash, zsh (.config/zsh), fish
├── theme/      gtk, qt, xsettings  toolkit theming
├── cli/        btop, cava, ...     fastfetch, htop
├── git/        .gitconfig          git identity and global ignore
├── xdg/        mimeapps.list       default application handlers
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

## Patches

`patches/` holds fixes for files HyDE installs and owns under `~/.local/lib/hyde`.
Those are program files rather than configuration, so they are not stow packages, and HyDE overwrites them on update.
Reapply with `patch -p1 --forward`, which is a no-op if the fix is already present.

See [patches/README.md](patches/README.md).
Currently one patch, restoring the `SUPER + /` keybindings hint menu, which broke because Hyprland 0.56 emits invalid JSON from `hyprctl binds -j`.

## Legacy configuration files

A HyDE update moved the framework from `.conf` files to a Lua configuration chain.
`~/.config/hypr/hyprland.conf` is no longer read, which silently orphaned every file it used to source.

These are still tracked as a record of the pre-migration state:

| File | Status |
|---|---|
| `keybindings.conf` | inert, 116 bind lines |
| `windowrules.conf` | inert |
| `userprefs.conf` | inert, blur and touchpad settings |
| `monitors.conf` | superseded by `monitors.lua` |
| `workflows.conf` | inert |

`keybindings.conf` is worth a note: it is HyDE's own default template from an older release rather than a personalised file.
Compared against the shipped default at `~/.local/share/hyde/keybindings.conf` it is 116 lines against 116, and only six bindings differ by intent.
The rest of the textual diff is HyDE modernising its own commands from `$scrPath/foo.sh` to `hyde-shell foo`.
So the bindings that changed across the update are upstream churn, not lost personal configuration.

Active configuration lives in `hyprland.lua`, which loads `keybindings.lua` last so it overrides HyDE's defaults.

`keybindings.lua` restores the pre-migration keyboard layout.
Only the bindings that actually changed are listed there, 27 of them; the remaining ~80 already match HyDE's current defaults and are left alone.
Verified against the old config: no binding is missing, and the handful that still report a difference differ only in their description text, not in the command they run.

Two old commands no longer exist upstream and were remapped.
`$scrPath/dontkillsteam.sh` became `hl.dsp.window.close()`, and `wbarconfgen` became `hyde-shell waybar -n` and `-p`.
