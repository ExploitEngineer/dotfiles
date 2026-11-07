<div align="center">

# dotfiles

**One wallpaper change repaints the whole Arch Linux desktop, terminal tools included.**

[![check](https://github.com/ExploitEngineer/dotfiles/actions/workflows/check.yml/badge.svg)](https://github.com/ExploitEngineer/dotfiles/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?logoColor=black)
![Themes](https://img.shields.io/badge/themes-37-brightgreen)

![Desktop overview](assets/themes/1-Bit.jpg)

</div>

Configuration for an Arch Linux and [Hyprland](https://hypr.land) desktop on the [HyDE](https://github.com/HyDE-Project/HyDE) framework.
It layers on top of HyDE and contains only what differs from HyDE's defaults, so what you read here is the customisation and not a copy of the framework.

## Highlights

- **One theme, everywhere.**
  Switch theme or wallpaper and the desktop, the terminal and the CLI tools change together: waybar, rofi, kitty, swaync, neovim, tmux, lazygit, yazi, btop, fzf, eza, herdr and the login screen.
  [How the hooks work](docs/theme-hooks.md).
- **37 complete themes**, each with its own wallpaper and window layout.
- **Notifications with real design.**
  A glass card with depth, an accent edge and a per-theme shape, on swaync.
  [Details](docs/notifications.md).
- **A login screen that follows the theme**, with five structurally different layouts.
  [Details](docs/login-screen.md).
- **Video wallpapers** that need no keybind and keep theming working.
  [Details](docs/video-wallpapers.md).
- **Safe to adopt.**
  Everything installs as symlinks with GNU Stow, previews with a dry run, and removes with one command.
  The one personal package, `git`, is opt-in.
- **Tested.**
  CI checks every script, rejects hardcoded home directories, dry-runs the install and runs every theme hook.

## Gallery

A few of the 37 themes.
Every screenshot shows neovim, Dolphin, fastfetch and cava repainted together.

| | | |
|---|---|---|
| **Catppuccin Mocha** <br> ![Catppuccin Mocha](assets/themes/Catppuccin-Mocha.jpg) | **Rosé Pine** <br> ![Rosé Pine](assets/themes/Rose-Pine.jpg) | **Synth Wave** <br> ![Synth Wave](assets/themes/Synth-Wave.jpg) |
| **Bad Blood** <br> ![Bad Blood](assets/themes/Bad-Blood.jpg) | **Nier** <br> ![Nier](assets/themes/Nier.jpg) | **Catppuccin Latte** <br> ![Catppuccin Latte](assets/themes/Catppuccin-Latte.jpg) |

<details>
<summary>All 37 themes</summary>

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

</details>

<details>
<summary>Power menu and login screen</summary>

The themed `wlogout` power menu:

| | | |
|---|---|---|
| **1-Bit** <br> ![1-Bit wlogout](assets/extras/wlogout-1-Bit.jpg) | **Bad Blood** <br> ![Bad Blood wlogout](assets/extras/wlogout-Bad-Blood.jpg) | **Rosé Pine** <br> ![Rosé Pine wlogout](assets/extras/wlogout-Rose-Pine.jpg) |

The login screen, from `sddm/`.
See [docs/login-screen.md](docs/login-screen.md) for how it stays in sync and what has been verified.

| | | |
|---|---|---|
| **1-Bit** <br> ![1-Bit login](assets/sddm-preview/1-Bit.jpg) | **Bad Blood** <br> ![Bad Blood login](assets/sddm-preview/Bad-Blood.jpg) | **Rosé Pine** <br> ![Rosé Pine login](assets/sddm-preview/Rose-Pine.jpg) |
| **Synth Wave** <br> ![Synth Wave login](assets/sddm-preview/Synth-Wave.jpg) | **Catppuccin Mocha** <br> ![Catppuccin Mocha login](assets/sddm-preview/Catppuccin-Mocha.jpg) | |

</details>

## Quick start

You need Arch Linux with [HyDE](https://github.com/HyDE-Project/HyDE) installed.
Read [Make it yours first](#make-it-yours-first) before running the installer.

```sh
sudo pacman -S stow
git clone https://github.com/ExploitEngineer/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh -n     # preview every symlink, change nothing
./install.sh        # apply them
```

Install only some packages:

```sh
./install.sh hypr shell hyde
```

Remove the symlinks again, leaving the repository untouched:

```sh
./uninstall.sh
```

Then pick a theme from the HyDE theme menu, or change the wallpaper, and watch the tools follow.

### Make it yours first

This repository started as one person's laptop, so a few files describe that laptop.

| What | Where | What to do |
|---|---|---|
| Git identity | `git/.gitconfig` | Not installed by default. Put your own name and email in it, then run `./install.sh git`. |
| Monitors | `hypr/.config/hypr/monitors.lua` | Pins a 1920x1080 panel called `eDP-1`. Delete it and run `nwg-displays`, or edit the output name and mode. |
| NVIDIA | [docs/graphics.md](docs/graphics.md), the Brave launcher | Written for a hybrid laptop with an NVIDIA card. Skip it on AMD or Intel. |
| Neovim | [chadvim](https://github.com/ExploitEngineer/chadvim) | A separate repository. Clone it into `~/.config/nvim` if you want it. |
| Existing files | `~/.config` | Stow will not overwrite a real file. Move aside anything `./install.sh -n` reports as a conflict. |

Three system files cannot be symlinked from `$HOME`: `/etc/environment`, the kernel command line in `/etc/default/grub`, and a journald size limit.
They are documented with their exact contents in [docs/graphics.md](docs/graphics.md) and [docs/machine-notes.md](docs/machine-notes.md).

## What is in here

Each top-level directory is a Stow package that mirrors the path it targets under `$HOME`.

| Package | Holds |
|---|---|
| `hypr` | Hyprland (Lua configuration), hyprsunset, pyprland |
| `desktop` | waybar layout, browser flags, swaync entry point |
| `terminal` | tmux |
| `shell` | bash, zsh, fish, and the environment that points tools at their generated themes |
| `cli` | btop, cava, fastfetch, htop, lazygit, starship, bat |
| `hyde` | wallbash theme hooks, the 37 themes, video wallpaper support |
| `xdg` | default applications, `environment.d` |
| `dolphin` | Dolphin layout, see [docs/dolphin.md](docs/dolphin.md) |
| `git` | git identity (opt-in) |
| `sddm/` | the login theme and its installer, system files that are not stowed |
| `patches/` | fixes for files HyDE owns, see [docs/hyde-fixes.md](docs/hyde-fixes.md) |
| `scripts/` | helpers, for now the notification daemon switch |

kitty, rofi and wlogout need nothing here: HyDE's defaults and wallbash output already cover them.

## Tools that follow the theme

| Tool | How it follows the theme | Takes effect |
|---|---|---|
| [herdr](https://herdr.dev) | hook writes `[theme.custom]` | live |
| lazygit | hook writes `wallbash.yml` | next start |
| tmux | hook writes `wallbash.conf` | live |
| yazi | hook writes `theme.toml` | next start |
| btop | hook writes a `wallbash` theme | live |
| fzf | hook writes an options file | every new fzf |
| eza | hook writes `theme.yml` | next run |
| swaync | hook writes `wallbash-style.css` | live |
| starship, bat, fastfetch, htop | use the terminal's ANSI colours, no hook | always |

Here is the same hook on three themes:

| Theme | tmux status bar | active pane border |
|---|---|---|
| Catppuccin Mocha | `bg=#181825,fg=#a6aec8` | `fg=#87b0f9` |
| Nier | `bg=#131614,fg=#bcbab1` | `fg=#97b7b4` |
| Gruvbox Retro | `bg=#1f1f1f,fg=#c0b393` | `fg=#448488` |

A hook is a one-line `.dcol` file plus a short script that reads a shared palette, and adding one for your own tool takes a few minutes.
The walkthrough, with a complete working example, is in [docs/theme-hooks.md](docs/theme-hooks.md).

## Documentation

| Page | Covers |
|---|---|
| [docs/theme-hooks.md](docs/theme-hooks.md) | How tools follow the theme, and how to write a hook |
| [docs/notifications.md](docs/notifications.md) | The swaync design, the per-theme shapes, switching daemons |
| [docs/login-screen.md](docs/login-screen.md) | The SDDM theme, how it syncs, what was verified |
| [docs/video-wallpapers.md](docs/video-wallpapers.md) | Playing a video as the wallpaper with theming intact |
| [docs/dolphin.md](docs/dolphin.md) | The Dolphin layout and why two files differ from HyDE's |
| [docs/hyde-fixes.md](docs/hyde-fixes.md) | Patches for HyDE, and the dunst and swaync conflict |
| [docs/graphics.md](docs/graphics.md) | NVIDIA, VA-API, browser flags, why browsers crashed the desktop |
| [docs/machine-notes.md](docs/machine-notes.md) | Fixes for the author's laptop and the Hyprland `.conf` to Lua migration |
| [docs/maintaining.md](docs/maintaining.md) | Which files are deliberately not tracked, and how to check for drift |

## Contributing

Contributions are welcome, and the repository is set up to make them easy.
[CONTRIBUTING.md](CONTRIBUTING.md) explains the layout, the rules, and how to test a change without touching your own setup.
CI runs on every pull request and tells you what to fix.

Good places to start:

- **A hook for another tool.**
  Candidates: zellij, k9s, lazydocker, delta, gitui, ncspot, helix, atuin.
  Follow [docs/theme-hooks.md](docs/theme-hooks.md), and prefer the terminal's ANSI colours when the tool allows it.
- **fish support** for the lazygit and fzf variables in `shell/.config/shell/wallbash-env.sh`.
- **Light and low-contrast themes.**
  Look for unreadable text in the tools above on the themes you use, and open an issue with a screenshot.
- **Other hardware.**
  Notes and fixes for AMD, Intel or other laptops belong in `docs/`, not in the packages.
- **Documentation.**
  Anything that confused you while installing.

Questions and ideas are welcome in the issue tracker.

## Credits

Built on [HyDE](https://github.com/HyDE-Project/HyDE) and its wallbash colour engine, [GNU Stow](https://www.gnu.org/software/stow/), and [Hyprland](https://hypr.land).
Theme wallpapers belong to their original artists.
If you are one and want a wallpaper removed, open an issue.

## License

[MIT](LICENSE).
Use any of it, change it, share it.

## Author

Made by [ExploitEngineer](https://github.com/ExploitEngineer).
