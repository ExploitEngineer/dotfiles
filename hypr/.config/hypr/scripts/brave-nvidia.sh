#!/usr/bin/env bash
# Launches Brave pinned to the NVIDIA GPU.
#
# Chromium/Brave under Wayland (Ozone) does not respect the usual PRIME
# offload env vars (__NV_PRIME_RENDER_OFFLOAD etc) when picking a GPU - those
# are an X11/GLX-era mechanism. Under Wayland it picks its render node itself
# via --render-node-override, defaulting to whichever GPU drives the display
# (Intel, since the 2026-10-09 BIOS Hybrid Graphics switch). Passing that flag
# explicitly is the only thing that actually moves it onto the NVIDIA card.
# Confirmed via nvidia-smi showing the GPU process attached to the Quadro.
#
# The render node is resolved at launch, not hardcoded, the same way
# nvidia-offload.sh avoids a fixed /dev/dri/cardN: it survives a future BIOS
# change or card reordering.
#
# Use this for WebGPU-heavy sites the Intel iGPU can't handle (older Coffee
# Lake UHD P630, limited feature set) - not as the default browser launcher,
# since normal browsing on Intel is what keeps NVIDIA's BAR1 off the hook.
set -euo pipefail

nvidia_pci=$(lspci -d 10de: -n 2>/dev/null | head -1 | cut -d' ' -f1)
if [ -z "$nvidia_pci" ]; then
	echo "no NVIDIA GPU found via lspci" >&2
	exit 1
fi

render_node="/dev/dri/by-path/pci-0000:${nvidia_pci}-render"
if [ ! -e "$render_node" ]; then
	echo "render node not found: $render_node" >&2
	exit 1
fi

exec /usr/bin/brave-beta --render-node-override="$(readlink -f "$render_node")" "$@"
