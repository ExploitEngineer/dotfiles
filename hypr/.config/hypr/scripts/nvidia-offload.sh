#!/usr/bin/env bash
# Runs a command on the NVIDIA GPU via PRIME render offload, for use once the
# BIOS graphics mode is Hybrid and the Intel iGPU drives the desktop.
#
# No device paths are hardcoded: PRIME offload selects the GPU by vendor
# library and Vulkan layer, not by /dev/dri/cardN, so this works regardless
# of which card index Intel or NVIDIA end up at after the BIOS switch.
#
# Usage: nvidia-offload <command> [args...]
# Example keybind: bind(M .. " + SHIFT + G", hl.dsp.exec_cmd("nvidia-offload steam"))
set -euo pipefail

if [ "$#" -eq 0 ]; then
	echo "usage: nvidia-offload <command> [args...]" >&2
	exit 1
fi

export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only

exec "$@"
