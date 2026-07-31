# Patches

Fixes applied to files that HyDE installs and owns.

These live outside the stow packages on purpose.
Stow symlinks configuration into `$HOME`, but these targets are program files under `~/.local/lib/hyde`, and HyDE overwrites them on every update.
Keeping the patches here means the fix can be reapplied after an update instead of rediscovered.

## Applying

```sh
cd ~
patch -p1 --forward < ~/dotfiles/patches/0001-keybinds-hint-parse-plaintext.patch
```

`--forward` makes the command a no-op if the patch is already applied, so it is safe to rerun after a HyDE update.

## 0001-keybinds-hint-parse-plaintext.patch

Fixes `SUPER + /` (the keybindings hint menu) silently doing nothing.

`hyde-shell keybinds_hint` calls `hint-hyprland.py`, which read the bind list from `hyprctl binds -j`.
On Hyprland 0.56 that command emits invalid JSON.
Values are shifted into the wrong keys and strings are written unquoted:

```
"modmask": true,
"submap": "64",
"key": "false",
"keycode": T,
"allow_input_capture": [Launcher|Apps] terminal emulator,
```

`json.loads()` therefore always raised `JSONDecodeError`.
The handler for that exception sat inside a `while True:` loop and only slept, so the script hung forever, produced no output, and the calling shell script fell through to a `notify-send "Initialization failed"` that is easy to miss.

The plain-text `hyprctl binds` output is correct, so the patch parses that instead.
Bind flags are recovered from the header token, where `bind` is followed by `l` for locked, `e` for repeat, `r` for release, `m` for mouse, `n` for non-consuming and `d` for has-description, for example `bindled`.

All four output formats (`rofi`, `json`, `md`, `dmenu`) were verified working after the change.

This is an upstream bug in Hyprland's JSON serialiser, not in HyDE.
The patch is a local workaround until it is fixed upstream.
