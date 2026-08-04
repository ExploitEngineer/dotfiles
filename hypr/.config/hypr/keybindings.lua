-- Pre-Lua keybindings, restored.
--
-- HyDE's update replaced its .conf keybinding chain with a Lua one and changed
-- a number of defaults along the way. This file puts back the layout that was
-- in use before, and is loaded from hyprland.lua. Later bindings win, so
-- everything here overrides HyDE's equivalent.
--
-- Only bindings that actually differ are restored. The other ~80 are identical
-- to HyDE's current defaults and are left alone.
--
-- Commands are the modern `hyde-shell <name>` form, not the old
-- `$scrPath/<name>.sh` paths, which no longer exist. Two old scripts are gone
-- entirely upstream and are noted inline.

local M = "SUPER"

-- HyDE wraps hl.bind with a dedup that only replaces an existing binding when
-- the *flag signature* matches as well as the key combo (see hyde/binds.lua).
-- HyDE's screenshot binds carry `locked = true` while these do not, so the
-- signatures differed, nothing was replaced, and both bindings stayed live:
-- one press of SUPER+S fired the screenshot tool *and* the scratchpad toggle.
--
-- Unbinding explicitly first makes replacement unconditional, whatever flags
-- either side uses.
local normalize = (hyde.binds or {}).normalize

local function bind(keys, action, description, opts)
	opts = opts or {}
	opts.description = description
	pcall(hl.unbind, normalize and normalize(keys) or keys)
	hl.bind(keys, action, opts)
end

-- ── Scratchpad: deliberately NOT bound to the S keys ────────────────────────
-- The pre-Lua config had SUPER+S / SUPER+SHIFT+S / SUPER+ALT+S on the special
-- workspace, and restoring that here was wrong: those keys are used for
-- screenshots in practice, and taking them over meant SUPER+S threw windows
-- into a hidden workspace instead of capturing anything.
--
-- The S keys are left to HyDE, which binds them to snip / freeze-and-snip /
-- print-monitor.
--
-- The scratchpad itself is still worth having a key for: without one, any window
-- already sitting in the special workspace floats on top of every workspace with
-- no way to dismiss it. SUPER+grave is free and is what HyDE's own commented-out
-- example uses.
bind(M .. " + grave", hl.dsp.workspace.toggle_special(),
	"[Workspaces|Special workspace] toggle scratchpad")

-- Deliberately putting a window into the stash. On grave rather than S, both
-- because the S keys belong to screenshots and because grave is far harder to
-- hit by accident, which is how windows previously ended up stranded in there.
-- Moving a window back OUT needs no special bind: SUPER+SHIFT+<number> already
-- moves the focused window to a numbered workspace, and works from inside the
-- special workspace.
bind(M .. " + SHIFT + grave", hl.dsp.window.move({workspace = "special"}),
	"[Workspaces|Special workspace] move window to scratchpad")

-- ── Screenshots ─────────────────────────────────────────────────────────────
-- These duplicate HyDE's S-key screenshot bindings on the pre-Lua P keys.
-- Both sets work; they are different keys, not competing bindings.
bind(M .. " + P", hl.dsp.exec_cmd("hyde-shell screenshot s"),
	"[Utilities|Screenshot] snip screen")
bind(M .. " + CTRL + P", hl.dsp.exec_cmd("hyde-shell screenshot sf"),
	"[Utilities|Screenshot] freeze and snip screen")
bind(M .. " + ALT + P", hl.dsp.exec_cmd("hyde-shell screenshot m"),
	"[Utilities|Screenshot] print monitor", {locked = true})
bind("Print", hl.dsp.exec_cmd("hyde-shell screenshot p"),
	"[Utilities|Screenshot] print all monitors", {locked = true})

-- ── Wallpaper ───────────────────────────────────────────────────────────────
-- HyDE moved group navigation onto these. Group navigation stays available on
-- SUPER+CTRL+H / SUPER+CTRL+L, which hyprland.lua restores.
bind(M .. " + ALT + Right", hl.dsp.exec_cmd("hyde-shell wallpaper -Gn"),
	"[Theming and Wallpaper] next global wallpaper")
bind(M .. " + ALT + Left", hl.dsp.exec_cmd("hyde-shell wallpaper -Gp"),
	"[Theming and Wallpaper] previous global wallpaper")

-- ── Waybar layout ───────────────────────────────────────────────────────────
-- The old binding called wbarconfgen, which no longer ships. `hyde-shell
-- waybar -n/-p` is the current equivalent.
bind(M .. " + ALT + Up", hl.dsp.exec_cmd("hyde-shell waybar -n"),
	"[Theming and Wallpaper] next waybar layout")
bind(M .. " + ALT + Down", hl.dsp.exec_cmd("hyde-shell waybar -p"),
	"[Theming and Wallpaper] previous waybar layout")

-- ── Selectors ───────────────────────────────────────────────────────────────
bind(M .. " + SHIFT + Y", hl.dsp.exec_cmd("pkill -x rofi || hyde-shell animations --select"),
	"[Theming and Wallpaper] select animations")
bind(M .. " + SHIFT + U", hl.dsp.exec_cmd("pkill -x rofi || hyde-shell hyprlock --select"),
	"[Theming and Wallpaper] select hyprlock layout")
bind(M .. " + SHIFT + G", hl.dsp.exec_cmd("hyde-shell gamelauncher"),
	"[Launcher|Apps] open game launcher")

-- ── Window sizing ───────────────────────────────────────────────────────────
bind(M .. " + SHIFT + Right", hl.dsp.window.resize({x = 30, y = 0, relative = true}),
	"[Window Management|Resize] resize window right", {repeating = true})
bind(M .. " + SHIFT + Left", hl.dsp.window.resize({x = -30, y = 0, relative = true}),
	"[Window Management|Resize] resize window left", {repeating = true})
bind(M .. " + SHIFT + Up", hl.dsp.window.resize({x = 0, y = -30, relative = true}),
	"[Window Management|Resize] resize window up", {repeating = true})
bind(M .. " + SHIFT + Down", hl.dsp.window.resize({x = 0, y = 30, relative = true}),
	"[Window Management|Resize] resize window down", {repeating = true})

-- ── Window and session ──────────────────────────────────────────────────────
-- The old binding called dontkillsteam, which no longer ships upstream.
-- window.close() is the same behaviour HyDE now uses for SUPER+Q.
bind("ALT + F4", hl.dsp.window.close(),
	"[Window Management] close focused window")
bind(M .. " + Delete", hl.dsp.exec_cmd("hyde-shell logout"),
	"[Window Management] kill hyprland session")

-- ── Dropdown terminal ───────────────────────────────────────────────────────
-- pyprland scratchpad, defined as [scratchpads.console] in pyprland.toml.
bind(M .. " + ALT + T", hl.dsp.exec_cmd("hyde-shell pypr toggle console"),
	"[Launcher|Apps] dropdown terminal")

-- ── Workspace scrolling ─────────────────────────────────────────────────────
bind(M .. " + mouse_down", hl.dsp.focus({workspace = "e+1"}),
	"[Workspaces|Navigation|Mouse] next workspace")
bind(M .. " + mouse_up", hl.dsp.focus({workspace = "e-1"}),
	"[Workspaces|Navigation|Mouse] previous workspace")

-- ── Screen recording ────────────────────────────────────────────────────────
-- ~/.local/bin/rec-toggle: first press picks a region and starts recording,
-- second press stops it. Output lands in ~/capture.
-- Needs wf-recorder on Wayland (slurp is already present).
bind(M .. " + R", hl.dsp.exec_cmd("rec-toggle"),
	"[Utilities|Screen recording] toggle region screen recording")

-- ── Volume on the function row ──────────────────────────────────────────────
-- HyDE moved these to F10/F11/F12. As with brightness on F3/F4, the bare
-- keysym is what fn+F<n> sends while HP Action Keys mode is active.
-- HyDE's F10/F11/F12 bindings are left in place as well.
bind("F5", hl.dsp.exec_cmd("hyde-shell volumecontrol -o m"),
	"[Hardware Controls|Volume] toggle mute output", {locked = true})
bind("F6", hl.dsp.exec_cmd("hyde-shell volumecontrol -o d"),
	"[Hardware Controls|Volume] decrease volume", {locked = true, repeating = true})
bind("F7", hl.dsp.exec_cmd("hyde-shell volumecontrol -o i"),
	"[Hardware Controls|Volume] increase volume", {locked = true, repeating = true})
