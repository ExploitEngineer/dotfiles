# Contributing

Thanks for wanting to improve these dotfiles.
Fixes, new theme-aware tool hooks and documentation corrections are all welcome.

## How the repository works

Every top-level directory is a [GNU Stow](https://www.gnu.org/software/stow/) package.
A package mirrors the path it targets under `$HOME`, so `hypr/.config/hypr/hyprland.lua` ends up at `~/.config/hypr/hyprland.lua`.

| Package | Holds |
|---|---|
| `hypr` | Hyprland, hyprsunset, pyprland |
| `desktop` | waybar, browser flags |
| `terminal` | tmux |
| `shell` | bash, zsh, fish |
| `cli` | btop, cava, fastfetch, htop, lazygit, starship, bat |
| `git` | git identity (opt-in, personal) |
| `scripts` | helper scripts, not stow packages |
| `xdg` | default applications, environment.d |
| `hyde` | HyDE wallbash hooks and themes |
| `dolphin` | Dolphin layout |

`sddm/` and `patches/` are not stow packages.
`sddm/` is a system-level login theme with its own installer, and `patches/` holds fixes applied with `patch` to files HyDE owns.
`docs/` has the longer write-ups, and `assets/` has the screenshots used by the README.

This repository holds only what differs from HyDE's shipped defaults.
If a file is byte-identical to upstream, leave it out.

## Before you open a pull request

1. Preview the install against an empty home to prove nothing conflicts:

   ```sh
   mkdir -p /tmp/fakehome && HOME=/tmp/fakehome ./install.sh -n
   ```

2. Run the checks CI runs:

   ```sh
   for f in install.sh uninstall.sh scripts/*.sh hyde/.config/hyde/wallbash/scripts/*.sh; do bash -n "$f"; done
   ```

3. Search your diff for anything personal: your name, email, home directory, API keys, tokens.
   Use `$HOME` or `~` instead of an absolute path.

## Rules

- **No secrets or personal data.**
  `.gitignore` is a second line of defence, not the first.
- **No generated files.**
  Anything HyDE or wallbash rewrites on a theme change must not be tracked.
  See [docs/maintaining.md](docs/maintaining.md) for the list and the reasoning.
- **No machine-specific paths.**
  A config that only works on one laptop belongs in [docs/machine-notes.md](docs/machine-notes.md) as a note, not in a package.
- **Match the existing style.**
  Shell scripts are bash with `set -euo pipefail` where they run standalone.
  Wallbash hooks follow `hyde/.config/hyde/wallbash/scripts/lazygit-theme.sh`, the smallest example.
- **Documentation puts each sentence on its own line.**
  It keeps diffs small and reviews readable.

## Adding a theme-aware hook for another tool

A wallbash hook is two files in the `hyde` package:

- `hyde/.config/hyde/wallbash/always/<tool>.dcol` is one line, `/dev/null|${WALLBASH_SCRIPTS}/<tool>-theme.sh`, and tells HyDE to run the script on every theme and wallpaper change.
- `hyde/.config/hyde/wallbash/scripts/<tool>-theme.sh` reads the colours and writes the tool's config.

Import `lib/palette.py` rather than parsing colours yourself.
It reads `$HYDE_THEME_DIR/kitty.theme`, which every HyDE theme ships with literal values, and exposes named roles such as `accent`, `surface1` and `red`.
Reading that file avoids a race with the wallbash render that writes `~/.config/kitty/theme.conf`.
If a tool can use the terminal's 16 ANSI colours instead, prefer that and skip the hook, as `starship` and `bat` do.
Only edit a clearly marked block of the tool's config, and stand down if the user has their own settings there.
Own a generated file where the tool allows it, and add it to the generated-files list in `.gitignore`.
Make the script testable without touching the real config, for example through an environment variable that overrides the output path, as `herdr-theme.sh` does with `HERDR_CONFIG_PATH`.
Document the hook in the README.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/), with the package as the scope: `feat(hyde): ...`, `fix(shell): ...`, `docs: ...`.
Keep the subject under about 70 characters, and say why in the body when it is not obvious.

## Screenshots

Theme screenshots live in `assets/themes/` as JPEG, one per theme, named after the theme with spaces replaced by dashes.
Show a real, populated desktop and nothing private: no notifications, browser tabs, usernames or hostnames.

## Reporting a problem

Open an issue and say which package and which theme.
For anything visual, attach a screenshot.
