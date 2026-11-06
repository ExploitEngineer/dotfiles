# dotfiles

Personal configuration for an Arch Linux and Hyprland desktop running the [HyDE](https://github.com/HyDE-Project/HyDE) framework.

This repository holds only the files that differ from HyDE's shipped defaults.
Anything byte-identical to upstream is left out, so what remains is the actual customisation rather than a copy of HyDE.

![Desktop overview](assets/themes/1-Bit.jpg)

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
├── hypr/       .config/hypr        hyprland.lua, hyprsunset, pyprland
├── desktop/    .config/waybar      bar layout, browser flags
├── terminal/   .config/tmux        tmux
├── shell/      .bashrc .profile    bash, zsh (.config/zsh), fish
├── cli/        btop, cava, ...     fastfetch, htop
├── git/        .gitconfig          git identity and global ignore (opt-in, see Install)
├── xdg/        mimeapps.list       default handlers, environment.d
├── hyde/       .config/hyde        wallbash hooks (video wallpaper, herdr theme)
├── dolphin/    dolphinrc           Dolphin tabs and panel layout
├── sddm/                           login screen theme + installer (system files, not stowed)
└── patches/                        fixes for HyDE-owned program files
```

Not every configured program appears here.
kitty, rofi, dunst and wlogout are configured entirely by HyDE defaults and wallbash output, so there is nothing custom to track.

## Themes

HyDE drives theming from the active wallpaper through wallbash, and every theme below is a full set: wallpaper, GTK/Qt colours, waybar, rofi, kitty, dunst, cava, neovim and herdr all repainted together.
Neovim lives in its own repository, [chadvim](https://github.com/ExploitEngineer/chadvim), which reads wallbash's colours itself.
All 37 tracked themes are below, each shown live: neovim, Dolphin's home folder, fastfetch and cava.
The window arrangement itself varies per theme too, between a few hand-picked three and four pane layouts, rather than one fixed template repainted 37 times.
`1-Bit` is the one active in the screenshot at the top of this file.

| | | |
|---|---|---|
| **1-Bit** <br> ![1-Bit](assets/themes/1-Bit.jpg) | **Abyssal Wave** <br> ![Abyssal Wave](assets/themes/Abyssal-Wave.jpg) | **Agency** <br> ![Agency](assets/themes/Agency.jpg) |
| **AncientAliens** <br> ![AncientAliens](assets/themes/AncientAliens.jpg) | **Bad Blood** <br> ![Bad Blood](assets/themes/Bad-Blood.jpg) | **BlueSky** <br> ![BlueSky](assets/themes/BlueSky.jpg) |
| **Catppuccin Latte** <br> ![Catppuccin Latte](assets/themes/Catppuccin-Latte.jpg) | **Catppuccin Macchiato** <br> ![Catppuccin Macchiato](assets/themes/Catppuccin-Macchiato.jpg) | **Catppuccin Mocha** <br> ![Catppuccin Mocha](assets/themes/Catppuccin-Mocha.jpg) |
| **Chisa** <br> ![Chisa](assets/themes/Chisa.jpg) | **CIA** <br> ![CIA](assets/themes/CIA.jpg) | **Code Garden** <br> ![Code Garden](assets/themes/Code-Garden.jpg) |
| **Crimson Blade** <br> ![Crimson Blade](assets/themes/Crimson-Blade.jpg) | **Crimson Blue** <br> ![Crimson Blue](assets/themes/Crimson-Blue.jpg) | **DanDaDan** <br> ![DanDaDan](assets/themes/DanDaDan.jpg) |
| **DoomBringers** <br> ![DoomBringers](assets/themes/DoomBringers.jpg) | **Drawbridge** <br> ![Drawbridge](assets/themes/Drawbridge.jpg) | **FBI** <br> ![FBI](assets/themes/FBI.jpg) |
| **Graphite Mono** <br> ![Graphite Mono](assets/themes/Graphite-Mono.jpg) | **Greenify** <br> ![Greenify](assets/themes/Greenify.jpg) | **Green Lush** <br> ![Green Lush](assets/themes/Green-Lush.jpg) |
| **Grukai** <br> ![Grukai](assets/themes/Grukai.jpg) | **Gruvbox Retro** <br> ![Gruvbox Retro](assets/themes/Gruvbox-Retro.jpg) | **LimeFrenzy** <br> ![LimeFrenzy](assets/themes/LimeFrenzy.jpg) |
| **Lock In** <br> ![Lock In](assets/themes/Lock-In.jpg) | **Monterey Frost** <br> ![Monterey Frost](assets/themes/Monterey-Frost.jpg) | **Nier** <br> ![Nier](assets/themes/Nier.jpg) |
| **Obsidian Purple** <br> ![Obsidian Purple](assets/themes/Obsidian-Purple.jpg) | **Oregairu** <br> ![Oregairu](assets/themes/Oregairu.jpg) | **Oxo Carbon** <br> ![Oxo Carbon](assets/themes/Oxo-Carbon.jpg) |
| **Pixel Dream** <br> ![Pixel Dream](assets/themes/Pixel-Dream.jpg) | **Red Stone** <br> ![Red Stone](assets/themes/Red-Stone.jpg) | **Rosé Pine** <br> ![Rosé Pine](assets/themes/Rose-Pine.jpg) |
| **Scarlet Night** <br> ![Scarlet Night](assets/themes/Scarlet-Night.jpg) | **Soulsborne** <br> ![Soulsborne](assets/themes/Soulsborne.jpg) | **Synth Wave** <br> ![Synth Wave](assets/themes/Synth-Wave.jpg) |
| **Vanta Black** <br> ![Vanta Black](assets/themes/Vanta-Black.jpg) | | |

The themed `wlogout` power menu, for a few of the themes above:

| | | |
|---|---|---|
| **1-Bit** <br> ![1-Bit wlogout](assets/extras/wlogout-1-Bit.jpg) | **Bad Blood** <br> ![Bad Blood wlogout](assets/extras/wlogout-Bad-Blood.jpg) | **Rosé Pine** <br> ![Rosé Pine wlogout](assets/extras/wlogout-Rose-Pine.jpg) |

### Login screen

Stock SDDM does not follow the active HyDE theme; it stays on whatever theme was picked at install time.
`sddm/` is a custom QML SDDM theme, `hyde-wallbash`, that re-themes itself on every wallpaper change.
It has five structurally different layouts rather than one template recolored, each fed that theme's real wallbash colors and its own wallpaper.

The five themes below keep the layout they were designed around.
The other 32 are hashed onto one of the five by theme name, so a given theme always gets the same layout (`sddm/wallbash/scripts/pick_layout.py`).
Pure hashing was tried first and sent Bad Blood to the bottom-sheet layout, so the previews would not have matched the real login screen; hence the pins.

| | | |
|---|---|---|
| **1-Bit** <br> ![1-Bit login](assets/sddm-preview/1-Bit.jpg) | **Bad Blood** <br> ![Bad Blood login](assets/sddm-preview/Bad-Blood.jpg) | **Rosé Pine** <br> ![Rosé Pine login](assets/sddm-preview/Rose-Pine.jpg) |
| **Synth Wave** <br> ![Synth Wave login](assets/sddm-preview/Synth-Wave.jpg) | **Catppuccin Mocha** <br> ![Catppuccin Mocha login](assets/sddm-preview/Catppuccin-Mocha.jpg) | |

These images are renders of the HTML/CSS mockups of the layouts, not screenshots of the QML greeter.
They are the page alone, with no browser around it: `assets/sddm-preview/preview.html?clean#<scene>` hides the page's own scene switcher and label.
Open it directly in a browser, or regenerate an image with Playwright's `chrome-headless-shell --screenshot=out.png --window-size=1920,1080 --hide-scrollbars --virtual-time-budget=5000 "file://$PWD/assets/sddm-preview/preview.html?clean#bad-blood"`.
Scene names: `1-bit`, `bad-blood`, `rose-pine`, `synth-wave`, `catppuccin-mocha`.

**How it stays in sync.**
`wallbash/always/sddm-wallbash.dcol` runs on every wallpaper change and calls `sddm-wallbash.sh`, which writes `/etc/sddm-wallbash/current.conf` (colors, a copy of the wallpaper, the layout number).
The greeter renders before any user session exists and runs as the `sddm` user, which cannot read `$HOME` (mode 700), so the live state lives in `/etc/sddm-wallbash/`.
That directory is group-writable by a dedicated `sddm-wallbash` group instead of sitting behind a NOPASSWD sudoers rule, so no root helper runs on each wallpaper change.
`sddm-wallbash-boot.service` runs as root before SDDM, but only checks the state file is non-empty and restores defaults if not.
It never reads anything the group can write.

**Install.**
`install.sh` must be run by hand with sudo; it points SDDM at the new theme as its last step.
Look at it first, before installing anything:

```sh
cd sddm
sddm-greeter-qt6 --test-mode --theme "$PWD/theme"    # a window, layout 1, nothing installed
sudo ./install.sh                                    # theme, group, state dir, boot unit, Current=hyde-wallbash
```

Log out and back in once afterwards so the new group membership applies.
Until then the sync hook logs a warning and skips itself; the greeter falls back to the colors baked into `theme.conf`.

Roll back by restoring the config the installer backed up first:

```sh
sudo cp /etc/sddm.conf.d/backup_the_hyde_project.conf /etc/sddm.conf.d/the_hyde_project.conf
```

**What was and was not checked.**
All five layouts load in the real `sddm-greeter-qt6` without QML errors, checked through the journal (the greeter does not log to stderr).
A deliberately broken `Main.qml` was the negative control: it logs the parse error and the greeter falls back to SDDM's built-in theme instead of crashing, so a theme that fails to load should still leave a working login.
A first `--test-mode` run turned up two real bugs the earlier checks missed.
The password field had `focus=true` but `activeFocus=false`, because the focus chain broke above it (the Loader and the layout root), so typing went nowhere until you clicked the box.
And 1-Bit drew a blinking block beside the "PASS" label that was not connected to the field at all.
Both are fixed: the field now takes focus when a layout appears and draws its own caret, and all five layouts measure `activeFocus=true`.
Not yet checked: an actual boot into this greeter on this machine, and the power buttons, which are hidden in `--test-mode` because SDDM reports no power capabilities there.

**Known gaps between the mockups and the real greeter.**
Only the 1-Bit layout has been looked at in a real `--test-mode` window.
Rendering all five QML layouts offscreen with each theme's own wallpaper and wallbash colors showed two that are clearly worse than their mockups:
the Catppuccin bottom sheet comes out pink with low-contrast blue text and inverted button colors, and Bad Blood's red glow becomes flat gray discs that wash out the wallpaper.
Rosé Pine's clock uses the system serif, and no layout can use blur or shader effects.
These are bugs in the QML translation, not the design, and are not fixed yet.

**Fonts.**
The QML asks only for generic `serif` and `monospace`, because the greeter runs as `sddm` and sees system fonts only.
Rosé Pine's italic clock is therefore the system serif, not the Playfair Display used in the mockup.
No GraphicalEffects or shaders anywhere, given this machine's GPU history; blur and glow are plain overlays and gradients.

## Install

Install HyDE first.
This repository layers on top of it and does not replace it.

### Make it yours before you run it

This started as one person's laptop, so a few files describe that laptop.
Read this list first.

- **Git identity.** The `git` package is not installed by default, because `git/.gitconfig` carries someone else's name and email.
  Put your own in it, then run `./install.sh git`.
- **Monitors.** `hypr/.config/hypr/monitors.lua` pins a 1920x1080 panel called `eDP-1`.
  Delete it and generate your own with `nwg-displays`, or edit the output name and mode.
  `hyprland.lua` falls back to a safe rule when the file is missing.
- **NVIDIA.** The graphics notes and the Brave launcher assume a hybrid laptop with an NVIDIA card.
  Skip [Graphics](docs/graphics.md) entirely on AMD or Intel.
- **Neovim.** Not part of this repository.
  Clone [chadvim](https://github.com/ExploitEngineer/chadvim) into `~/.config/nvim` if you want it.
- **Existing files.** Stow refuses to overwrite a real file.
  Run `./install.sh -n` first, and move aside anything it reports as a conflict.

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
| `/etc/environment` | [Graphics](docs/graphics.md) |
| `/etc/default/grub` kernel command line | [Graphics](docs/graphics.md), [Machine-specific notes](docs/machine-notes.md) |
| `/etc/systemd/journald.conf.d/00-size.conf` | `SystemMaxUse=500M`, or the journal grows unbounded |

Also install `libva-nvidia-driver` and `libva-utils`, and enable `fstrim.timer`, which is off by default on Arch.

## Dolphin

Dolphin stays the file manager, with HyDE's layout: Places and Information panels docked on the right and an icon-only toolbar.
Only two files differ from HyDE's shipped copies, and `dolphinui.rc` and the global view properties are left to HyDE.

`dolphinrc` adds `RememberOpenedTabs=false`.
With the default, Dolphin reopens every tab from the last session, which piled up a dozen tabs and kept the tab bar permanently on screen.
It also keeps HyDE's `ToolBarsMovable=Disabled`, which Dolphin drops when the toolbar is dragged, letting it drift out of the layout.

`.local/state/dolphinstaterc` is HyDE's window state with the Terminal panel hidden.
HyDE's state leaves that panel visible, but HyDE does not install Konsole, so the panel only ever shows "Terminal cannot be shown because Konsole is not installed".
The panel's visibility is a flag byte in the base64 `State=` blob, not a readable key, so it was toggled by editing that byte.

`kdeglobals` is not tracked: `color.set.sh` rewrites its colours on every theme switch.

## Video wallpapers

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

### Notes

The pointer to the current wallpaper is `$HYDE_CACHE_HOME/wall.set`, a symlink that `wallpaper.sh:77` calls `wallCur`.
Do not use `wall.awww.png` for this: it only exists for some themes, and where it does exist it is sometimes a real file rather than a symlink, so resolving it returns its own path.

`hwdec=auto-safe`, not `hwdec=nvdec`.
It resolves to nvdec on this machine, but the Quadro P1000 is Pascal and has no AV1 decoder, so a pinned `nvdec` would fail outright on an AV1 file instead of falling back to software.
Prefer H.264 or HEVC anyway, both of which are real NVDEC here, as is VP9.

`-p -a MAX` pauses playback whenever the wallpaper is covered, which on a laptop is most of the time.

Measured on a 1080p30 clip: `utilization.decoder` around 5 percent and roughly 417 MiB of VRAM.
That VRAM figure is worth remembering on a 4 GB card.

## herdr theme

[herdr](https://herdr.dev) has no HyDE integration, only a `[theme.custom]` table in `~/.config/herdr/config.toml`.
`hyde/.config/hyde/wallbash/scripts/herdr-theme.sh` fills that table from the active theme's `kitty.theme`, so herdr matches the terminal around it.
It runs from `wallbash/always/herdr.dcol` on every theme and wallpaper change, and reloads a running herdr server, so no restart is needed.

- Every HyDE theme ships a `kitty.theme` with literal colours, which is why that file is the source and not wallbash's `dcol_*` variables.
  It is also read directly rather than through `~/.config/kitty/theme.conf`, which avoids racing the render that writes it.
- Background, foreground and the red, green, yellow, blue, magenta and cyan ANSI colours map straight across.
  The surface and overlay greys are mixed between background and foreground in the same steps Catppuccin uses, so light themes work without a special case.
- Only the block between the `>>> wallbash >>>` and `<<< wallbash <<<` markers is managed.
  The rest of `config.toml` is untouched.
  A hand-written `[theme]` table outside the block makes the script stand down, because TOML forbids defining it twice.
- Test without touching the real config:
  `HERDR_CONFIG_PATH=/tmp/herdr.toml HYDE_THEME_DIR=~/.config/hyde/themes/Nier ~/.config/hyde/wallbash/scripts/herdr-theme.sh`

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

## More documentation

| Page | Covers |
|---|---|
| [docs/graphics.md](docs/graphics.md) | NVIDIA setup, VA-API, browser flags, why browsers crashed the desktop |
| [docs/machine-notes.md](docs/machine-notes.md) | Fixes for the author's laptop, and the Hyprland `.conf` to Lua migration |
| [docs/maintaining.md](docs/maintaining.md) | Why some files are not tracked, and how to check for drift |

## Contributing

Pull requests are welcome, especially hooks that make another tool follow the active HyDE theme.
[CONTRIBUTING.md](CONTRIBUTING.md) explains the layout, the rules and how to test a change without touching your own setup.

## License

[MIT](LICENSE).
Use any of it, change it, share it.

## Author

Made by [ExploitEngineer](https://github.com/ExploitEngineer).
