# sddm-hyde-wallbash

An SDDM (login screen) theme for HyDE/Hyprland/Arch that recolors itself from HyDE's
wallbash color-extraction system, plus the sync mechanism and installer that keep it
live.

This directory is meant to be inspected by hand before anything in it touches a
root-owned path. Nothing here has been copied into `/usr/share/sddm/`, `/etc/`, or
`/etc/systemd/system/` yet - that only happens when you run `install.sh` yourself.

## What's inside

```
theme/      the QML theme itself - copy target: /usr/share/sddm/themes/hyde-wallbash/
wallbash/   the wallbash sync hook - copy target: ~/.config/hyde/wallbash/
systemd/    the boot-time self-heal unit + its root-owned script and default state
install.sh  the installer - the only thing you should actually run
```

Five compositions, ported from the approved HTML/CSS mockup
(`/tmp/sddm_preview/preview.html`): 1-Bit, Bad Blood, Rosé Pine, Synth Wave, Catppuccin
Mocha. `wallbash/scripts/pick_layout.py` hashes the active HyDE theme's name to pick one
deterministically - the same theme always gets the same composition, and all five get
roughly even coverage across HyDE's 37+ themes.

## Test this before you trust it

This is boot-critical code - a broken SDDM theme can leave you unable to log in
graphically. Before doing anything else, after running the installer:

```
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hyde-wallbash
```

This opens the greeter in a normal window, on your running desktop, without touching the
real login session at all. Look at all five compositions by changing
`/etc/sddm-wallbash/current.conf`'s `Template=` value (1-5) and re-running the command -
no wallpaper change needed just to preview them.

Do **not** restart or reload the real `sddm` service, and do **not** reboot, until
`--test-mode` looks right. `install.sh` itself never touches the running service - that
step is always yours, deliberately.

## Install

```
sudo ./install.sh
```

Safe to re-run. It will not overwrite `/etc/sddm.conf.d/backup_the_hyde_project.conf` (or
create a second backup) if one already exists, and it will not overwrite
`/etc/sddm-wallbash/current.conf` if real wallbash state is already there from a previous
run.

One manual step after installing, once: log out and back in (or run `newgrp
sddm-wallbash`) so the group membership the installer just granted you actually takes
effect in your shell/session. Until then, wallpaper changes will skip the sync step with
a logged warning rather than fail - the greeter still shows a correct, baked-in fallback
either way.

## Roll back

```
sudo cp /etc/sddm.conf.d/backup_the_hyde_project.conf /etc/sddm.conf.d/the_hyde_project.conf
sudo rm -f /etc/sddm.conf.d/hyde-wallbash-env.conf
sudo systemctl disable sddm-wallbash-boot.service
sudo rm -rf /usr/share/sddm/themes/hyde-wallbash /usr/local/lib/sddm-wallbash /etc/sddm-wallbash
rm -rf ~/.config/hyde/wallbash/always/sddm-wallbash.dcol ~/.config/hyde/wallbash/scripts/sddm-wallbash.sh ~/.config/hyde/wallbash/scripts/pick_layout.py
```

That restores whichever theme `Current=` pointed at before (`elarun`, on this machine, at
the time this was built).

## What this agent actually verified, and what it didn't

Verified from this environment, not just by reading the code:

- `qmllint` against every `.qml` file (clean, no warnings).
- Every QML file actually **instantiated** via `qml6` in offscreen mode with mock
  `sddm`/`config`/`userModel`/`sessionModel` context objects standing in for what the
  real SDDM greeter provides - this caught several real defects static linting missed
  (a fractional `font.pixelSize` that silently failed component creation on this Qt
  6.11 runtime, a `PropertyAction` whose `target: parent` resolved to the wrong object,
  a grouped-vs-dotted `font` property conflict, and more) - all fixed and re-verified
  this way, including a full run of `Main.qml` itself switching between all 5
  `Template` values plus an out-of-range value to confirm the safe fallback.
- That `XMLHttpRequest` against a `file://` URL - how `Main.qml` reads the live
  override - returns empty by default on this Qt 6 runtime unless
  `QML_XHR_ALLOW_FILE_READ=1` is set, confirmed empirically; `install.sh` now sets that
  through SDDM's own `GreeterEnvironment=` config key (confirmed real via
  `sddm --example-config`), not a guess.
- A full dry run of `wallbash/scripts/sddm-wallbash.sh`'s logic against a fake
  group-writable state dir, using this machine's real `$HYDE_THEME`/`wall.set`, which
  produced a correctly-formatted `current.conf` and wallpaper copy; separately, that it
  degrades to a clean, non-fatal warning when `/etc/sddm-wallbash/` doesn't exist (the
  real state on this machine right now, since nothing has sudo-installed it yet).
- `bash -n` against every shell script, a Python syntax + functional check on
  `pick_layout.py` (including that the same theme name always maps to the same
  Template), and that every path `install.sh` references exists in this tree.

Not verified, and not verifiable without sudo or a running SDDM session: an actual
graphical login, the sddm-wallbash group-membership boundary working end to end, the
systemd unit actually running before `sddm.service` at a real boot, or whether this looks
right on an HDPI/multi-monitor setup. That is what the `--test-mode` command above is
for - run it yourself before trusting any of this at boot.
