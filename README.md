# dotfiles

Personal configuration for an Arch Linux and Hyprland desktop running the [HyDE](https://github.com/HyDE-Project/HyDE) framework.

This repository holds only the files that differ from HyDE's shipped defaults.
Anything byte-identical to upstream is deliberately left out, so what remains is the actual customisation rather than a copy of someone else's project.

## System

| | |
|---|---|
| Distribution | Arch Linux (`linux-lts`) |
| Hardware | HP ZBook Studio x360 G5 |
| Compositor | Hyprland 0.56.0 |
| Framework | HyDE, Lua configuration mode |
| Shell | zsh with powerlevel10k |
| Bar | waybar |
| Launcher | rofi |
| Notifications | dunst |
| Lock and idle | hyprlock, hypridle |

## Layout

Packages are [GNU Stow](https://www.gnu.org/software/stow/) directories.
Each one mirrors the path it targets under `$HOME`, which means a package can be installed or removed on its own.

```
dotfiles/
├── hypr/       .config/hypr        Hyprland, hyprlock, hyprsunset, pyprland
├── desktop/    .config/waybar      bar layout and user styling
├── terminal/   .config/tmux        terminal multiplexer
├── shell/      .zshrc .bashrc      zsh, bash, fish, login profiles
├── theme/      gtk, qt, xsettings  toolkit theming
├── cli/        btop cava htop ...  terminal tools
├── git/        .gitconfig          git identity and global ignore
└── xdg/        mimeapps.list       default application handlers
```

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

## What is not tracked, and why

Nothing here is curated by accident.
Files are copied in by an explicit allowlist, and `.gitignore` is a second line of defence so that a careless `git add -A` cannot publish a credential.

**Credentials and keys.**
`.ssh`, `.gnupg`, `.docker`, `.npmrc`, `.mcp-auth`, `.claude.json`, and anything matching a private key or token pattern.

**Tools that store API keys.**
`gh`, `nuclei`, `subfinder`, `uncover`, `amass`, `katana`, `ffuf`, `feroxbuster`, `wakatime`, `msf4`, and Burp Suite.
Several of these hold live provider keys, and the rest will once they are configured.

**Saved connections and passwords.**
`remmina`, `beekeeper-studio`, `MongoDB Compass`, `qBittorrent`, and `tigervnc`.

**Browser profiles.**
Cookies and saved passwords live in these directories, so none of them are tracked.

**Shell and tool history.**
`.zsh_history`, `fish_history`, `htop_history`, `.viminfo`, `.netrwhist`, and similar.

**Generated output.**
HyDE regenerates a large amount of configuration from the active wallpaper through wallbash.
Tracking it would produce a diff on every theme change and would overwrite itself on restore.
That covers `.config/hypr/themes/`, `waybar/theme.css`, `waybar/style.css`, `waybar/includes/`, `rofi/theme.rasi`, `dunst/dunstrc`, `kitty/theme.conf`, the `wallbash` colour files under `qt5ct`, `qt6ct`, `Kvantum`, and `vim`, plus compiled shader and zsh completion caches.

## Machine-specific notes

These are fixes for this particular laptop, kept here so a future restore does not have to rediscover them.
All of them live in `hypr/.config/hypr/hyprland.lua`.

**Display scale.**
Hyprland's built-in default is `,preferred,auto,auto`, and `auto` resolves to a scale of 1.5 on this panel, which reduces a 1920x1080 display to a 1280x720 logical desktop.
Scale is pinned to 1.0.
`nwg-displays` writes `monitors.lua`, but nothing in HyDE's Lua chain requires that file, so `hyprland.lua` loads it explicitly and falls back to a known-good rule if it is missing.

**Numlock.**
HyDE sets `input.numlock_by_default = true`.
On this keyboard the embedded numpad overlay rides on numlock, which turns `u i o j k l m p` into `4 5 6 1 2 3 0 *`.
It is forced off.

**Brightness keys.**
This machine never emits `XF86MonBrightnessUp` or `XF86MonBrightnessDown`.
Sweeping the whole function row produces only volume and mic-mute keysyms, so HyDE's stock hardware bindings can never fire.
Brightness is bound to `SUPER + SHIFT + Up` and `SUPER + SHIFT + Down`, and additionally to bare `F3` and `F4`, which is what the function row sends while HP Action Keys mode is active.

**Blue light filter.**
HyDE ships a `blue-light-filter` screen shader and enables `hyprsunset`.
Together they tint the display noticeably.
The shader is set to `disable` and hyprsunset is left at a neutral 6500K.

## Patches

`patches/` holds fixes for files that HyDE installs and owns under `~/.local/lib/hyde`.
Those are program files rather than configuration, so they are not stow packages, and HyDE overwrites them on update.
Reapply them after an update with `patch -p1 --forward`, which is a no-op if the fix is already present.

See [patches/README.md](patches/README.md) for details.
Currently one patch, restoring the `SUPER + /` keybindings hint menu, which broke because Hyprland 0.56 emits invalid JSON from `hyprctl binds -j`.

## Legacy configuration files

A HyDE update moved the framework from `.conf` files to a Lua configuration chain.
`~/.config/hypr/hyprland.conf` is no longer read, which silently orphaned every file it used to source.

The affected files are still tracked here as a record, because they contain personal customisation that has not been ported yet:

| File | Status |
|---|---|
| `keybindings.conf` | inert, roughly 116 personal bindings awaiting port |
| `windowrules.conf` | inert |
| `userprefs.conf` | inert, blur and touchpad settings |
| `monitors.conf` | superseded by `monitors.lua` |
| `workflows.conf`, `workspaces.conf` | inert |

Active configuration lives in `hyprland.lua`.
Bindings ported so far include the group navigation pair `SUPER + CTRL + H` and `SUPER + CTRL + L`.

## Licence

Configuration files, use freely.
