# Patches

Fixes applied to files that HyDE installs and owns.

These live outside the stow packages on purpose.
Stow symlinks configuration into `$HOME`, but these targets are program files under `~/.local/lib/hyde`, and HyDE overwrites them on every update.
Keeping the patches here means the fix can be reapplied after an update instead of rediscovered.

## Applying

```sh
cd ~
for p in ~/dotfiles/patches/*.patch; do patch -p1 --forward -r - < "$p"; done
```

`--forward` makes the command a no-op if the patch is already applied, so it is safe to rerun after a HyDE update.
An already-applied patch still exits non-zero and would otherwise drop a `.rej` file next to the target, so `-r -` discards the rejects and keeps a rerun clean.

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

## 0002-grimblast-single-slurp.patch

Fixes every area screenshot asking for the region to be drawn twice.

`SUPER + S`, `SUPER + SHIFT + S` and `SUPER + CTRL + S` all reach `screenshot.sh`, which runs `grimblast copysave area`.
The copy of `grimblast` that HyDE installs calls `slurp` twice in `area()`:

```sh
GEOM="$(echo -n "$rects" | slurp -o "${SLURP_ARGS[@]}")"
# use `|` as separator for stableId label
choice="$(echo -n "$rects" | slurp "${SLURP_ARGS[@]}" -f "%x,%y %wx%h|%l")"
```

One keypress therefore opened two region selectors back to back.
The first selection was then thrown away by the line below them, `[[ -z "$WINDOW" ]] && GEOM="${choice%|*}"`, which overwrites `GEOM` from the second call for any freehand drag.
That is why the first drag appeared to do nothing and the second one was always what got captured.

Upstream has a single call that carries both the `-o` flag and the label format, and the patch restores it.
The extra line looks like a bad merge in HyDE's vendored copy: it kept the old geometry-only call and dropped `-o` from the new labelled one.

Verified with a stubbed `slurp` on `PATH`, one invocation for each path where the installed copy made two: a freehand drag captures the drawn region at the requested size, a click on a window captures that window through `grim -T <stableId>`, and cancelling the selection writes no file.
