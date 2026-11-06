# Graphics

Notes from an HP ZBook with an NVIDIA Quadro P1000 on Arch.
Skip this page on AMD or Intel graphics.

NVIDIA Quadro P1000 Mobile (GP107GLM), 4 GB, driver 580, `nvidia-580xx-dkms` from chaotic-aur.
Single GPU: there is no Intel iGPU visible to the OS on this machine, so nothing here is about hybrid graphics or PRIME offload.

This section is the whole story, so it does not have to be rediscovered or re-explained.

## Hybrid graphics was tried and reverted (2026-10-09)

The BIOS graphics mode was switched from discrete-only to Hybrid for a few hours on 2026-10-09, to see whether moving the Intel UHD P630 iGPU onto scanout duty (keeping NVIDIA offload-only) would reduce exposure to the BAR1-exhaustion Xid faults documented below.
Reverted the same day after two live Hyprland crashes.

What worked: PRIME render offload to NVIDIA for GLX/EGL apps, confirmed via `nvidia-smi`.
What didn't: Chromium/Brave under Wayland ignores PRIME offload env vars entirely and needs an explicit `--render-node-override` instead; Intel had no Vulkan driver installed out of the box, breaking WebGPU on some sites until `vulkan-intel` and `intel-media-driver` were installed.

What ended it: a `coredumpctl` trace caught Hyprland itself aborting mid-frame, not an NVIDIA Xid fault.

```
CMonitorFrameScheduler::onFrame -> renderMonitor -> CHyprGLRenderer::endRender
-> CEGLSync::create -> Mesa EGL -> libgallium (Intel's driver) -> abort
```

Crashed inside Mesa's Intel Gallium driver during EGL sync-fence creation on a DRM page flip, and the crashed process was already running with `--watchdog-fd --safe-mode`, meaning it was not the first occurrence that session.
`awww-daemon` and waybar both aborted in the same instant, consistent with losing the compositor out from under them.
Root cause not isolated beyond that trace (plain Mesa/iGPU bug vs. a cross-GPU buffer-sync issue between Intel scanout and NVIDIA offload are both plausible), and was not worth chasing further given the discrete-only baseline is a known, already-diagnosed quantity.

Net effect: trading the known Xid 79 / BAR1 risk for an unknown Mesa/Intel compositor-crash risk was not a clear improvement, so back to discrete-only.
If this is tried again, start from `git log --diff-filter=D -- 'hypr/.config/hypr/scripts/nvidia-offload.sh' 'hypr/.config/hypr/scripts/brave-nvidia.sh' 'xdg/.local/share/applications/brave-browser-beta-nvidia.desktop'` for the PRIME offload wrapper and the NVIDIA-pinned Brave launcher, both working, just removed as dead weight once there was only one GPU again.

## The GPU was never the problem

Rendering has always been on the Quadro.
Hyprland, kitty, Brave and Xwayland all hold memory on it, Hyprland runs on the `drm` backend against the NVIDIA module, and Brave's GPU process opens `/dev/dri/renderD128`.

What was missing is **hardware video decode**.
`libva` was installed but `libva-nvidia-driver` was not, so there was no `nvidia_drv_video.so` under `/usr/lib/dri/`, and every browser and Electron app decoded video on the CPU.
That is what "the system is not using the GPU" actually meant: high CPU on video, fans, heat.
It was structurally impossible for `utilization.decoder` to leave 0.

## HyDE's environment mechanism emits nothing

`~/.local/share/hypr/lua/env.lua` sets `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME` and `GBM_BACKEND` through `hl.env()`, and `variables.lua` sets `MOZ_ENABLE_WAYLAND` and `ELECTRON_OZONE_PLATFORM_HINT` the same way.
None of them arrive.
The compiled config at `~/.local/state/hyde/hyprland.conf` contains **zero** `env =` lines, and reading `/proc/<pid>/environ` for waybar, kitty and Hyprland itself finds none of these variables set.

Do not try to fix this by editing `env.lua` or by adding `hl.env()` calls to `userprefs.lua`.
Both go through the same mechanism and both do nothing.

Two further things defeat the Hyprland-side approach even where it works.
waybar is started by `systemd --user`, not by Hyprland, so a Hyprland `env =` line would never reach it.
And SDDM starts the session through a login shell rather than the systemd user manager, so `~/.config/environment.d` alone does not reach Hyprland either.

## Where the variables actually live

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

## Packages

```sh
sudo pacman -S --needed libva-nvidia-driver libva-utils
```

`libva-nvidia-driver` provides `/usr/lib/dri/nvidia_drv_video.so`, which is the whole fix.
`libva-utils` provides `vainfo` and is only needed to verify.

## Browser flags

The filename matters.
`/usr/bin/brave-beta` reads `$XDG_CONFIG_HOME/brave-beta-flags.conf`, so a file named `brave-flags.conf` is silently ignored and nothing tells you.
Chrome reads `chrome-flags.conf`.
Both are in `desktop/` and both contain:

```
--ozone-platform-hint=auto
--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncodeLinuxGL,AcceleratedVideoDecodeLinuxGL
--disable-features=UseChromeOSDirectVideoDecoder
```

## BAR1 exhaustion: why browsers crash the whole desktop

The Quadro P1000 is Pascal GP107 with **BAR1 = 256 MiB and no resizable BAR**.
BAR1 is the only CPU-mappable window into the 4 GB of VRAM, and on Pascal it cannot be enlarged.

Under Chromium GPU workload that address space exhausts, `__nv_drm_gem_nvkms_map` then requests a range past the BAR boundary, and the kernel rejects it.
That is the `Failed to map NvKmsKapiMemory` in the journal.
It is documented upstream as [NVIDIA/open-gpu-kernel-modules#1134](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1134).

The failure escalates:

```
BAR1 VA exhausted
  -> Failed to map NvKmsKapiMemory        single tab freezes
  -> Xid 32 corrupted push buffer         every GPU client at once
  -> Hyprland SIGABRT                     desktop dies, hard power-off
```

On 2026-08-29 the escalated form fired: 135 Xid 32 errors in one instant across kitty, brave, Xwayland, Xorg, Hyprland and a udev-worker.

**Do not enable VA-API on this card.**
Every decoded frame costs another BAR1 mapping on a window that is already the bottleneck, and turning it on is what took the failure from frozen tabs to a dead compositor.
`nvidia-vaapi-driver`'s own README calls Chromium support experimental with "not much success".
Its EGL backend is broken on drivers 525 and later, so `NVD_BACKEND=egl` is not a safe fallback either; `direct` is the only working backend and it is the one that failed here.

Video therefore decodes on CPU. That is the correct trade on a 256 MiB BAR1.

The browser flags in `desktop/` keep GPU rendering and rasterization enabled, which is what makes 3D and animated pages fast, while removing the per-frame mappings:

| Flag | Why |
|---|---|
| `--disable-features=AcceleratedVideoDecodeLinuxZeroCopyGL` | zero-copy maps a GPU buffer per frame straight into BAR1, the largest single source of pressure |
| `--disable-gpu-memory-buffer-video-frames` | stops video frames being allocated as mapped GPU memory buffers |
| `--ozone-platform-hint=auto` | native Wayland, unrelated to the fault |

Check flag names against the binary before adding any more.
`VaapiVideoDecodeLinuxGL` was set here for a while and does not exist in Brave 152:

```sh
grep -ac -- "SomeFeatureName" /opt/brave.com/brave-beta/brave
```

If a crash ever recurs, `--ozone-platform=x11` drops Brave to XWayland and avoids the compositor buffer path entirely.

Watch for recurrence with:

```sh
journalctl -b -q | grep -c "NVRM: Xid"
```

## Kernel command line

```
GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 loglevel=7"
```

`nvidia_drm.modeset=1` is required by Hyprland and must stay.
See [Machine-specific notes](machine-notes.md) for `nvidia_drm.fbdev=1`, mkinitcpio `MODULES` and the SDDM display server, all of which look like reasonable additions here and all of which break this laptop.

## Verifying

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
