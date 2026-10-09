-- Personal preferences, restored from the pre-Lua userprefs.conf.
--
-- WHY THIS FILE WINS ON EVERY THEME
--
-- HyDE's load order is: defaults -> dynamic.lua (which applies the active
-- theme) -> ... -> hyprland.lua. This file is required from hyprland.lua, so
-- it is applied after the theme and overrides it.
--
-- Theme switching does not bypass that. hyde-shell theme.switch ends in
-- color.set.sh, which has `trap 'hyprctl reload -q' EXIT`, so every switch
-- triggers a full config reload and this file is re-applied on top.
--
-- Putting these in userprefs.conf no longer works: HyDE stopped reading
-- ~/.config/hypr/hyprland.conf when it moved to the Lua chain, which silently
-- orphaned that file and every other .conf it used to source.

-- Default blur, applied to every theme.
local blur = {
	enabled = true,
	size = 4,
	passes = 2,
	new_optimizations = true,
	ignore_opacity = true,
	xray = false,
}

-- Default window opacity. This, not the blur radius, is what decides whether
-- blur is *visible*: at 0.90 only a tenth of the blurred backdrop shows through,
-- so the window reads as solid however large the blur is.
local opacity = { active = 0.90, inactive = 0.75 }

-- Per-theme overrides. Because this file is applied after the theme, editing a
-- theme's own hypr.theme has no effect; overrides have to happen here.
--
--   active/inactive  window opacity. LOWER = more of the blurred backdrop is
--                    visible. This is the main dial for "more blur".
--   size             blur sample radius; wider smear.
--   passes           blur iterations. Raising this too far flattens the result
--                    into a uniform wash that looks like no blur at all, so 3
--                    is about the practical ceiling for a visible effect.
--
-- The active theme name comes from hyde.config.ui.hyde_theme, which dynamic.lua
-- populates from lua_state/ui.lua before hyprland.lua is loaded.
-- Red Stone needs more transparency than the rest, for two structural reasons:
--
--   1. Its window background is #0A0101, essentially pure black, against Rosé
--      Pine's #191724. What you see is 0.9 * window_bg + 0.1 * blurred wallpaper,
--      so a black background swallows the result.
--   2. Its wallpapers are unusually dark. The brightest is 55.9% mean lightness
--      but most sit under 15%, against Rosé Pine's 24.3%.
--
-- Lowering opacity is the only dial that raises the wallpaper's contribution.
-- Blur radius does not: it decides how smeared that contribution is, not how
-- much of it there is, and pushing size past ~6 destroys fine wallpaper detail.
-- 0.65/0.58 was picked by eye against Red Stone's wallpaper. It is roughly the
-- transparency floor for a terminal you actually read: much lower and text
-- starts competing with the wallpaper behind it.
local per_theme = {
	["Red Stone"] = { active = 0.65, inactive = 0.58, size = 6, passes = 2 },
}

local theme = (hyde.config.ui or {}).hyde_theme
for k, v in pairs(per_theme[theme] or {}) do
	if k == "active" or k == "inactive" then
		opacity[k] = v
	else
		blur[k] = v
	end
end

hl.config({
	-- Mouse resize by dragging a window edge. 1-Bit is the only theme of the 43
	-- that sets this to false, which silently removes edge-drag resize whenever
	-- it is active. Pinned true here so the behaviour does not depend on which
	-- theme is loaded. The grab area is extend_border_grab_area (15px default),
	-- so a theme's border_size does not have to be large for this to be usable.
	general = {
		resize_on_border = true,
	},

	decoration = {
		-- Opacity is the reason blur looked absent on some themes, not the blur
		-- settings themselves. Blur is enabled by all 43 themes, but several set
		-- active_opacity = 1, which makes the focused window fully opaque so the
		-- blurred content behind it cannot be shown. Crimson-Blue sets both
		-- opacities to 1 and xray = true, which removes it entirely.
		--
		-- Pinned here so themes cannot raise them back to 1. Remove these two
		-- lines if you would rather let each theme decide.
		active_opacity = opacity.active,
		inactive_opacity = opacity.inactive,

		blur = blur,
	},

	input = {
		touchpad = {
			natural_scroll = false,
		},
	},

	dwindle = {
		-- HyDE's default layout pins this to 2 (always split new windows into
		-- the bottom/right half of the focused window, never top/left). That
		-- is a fixed rule, not cursor-based placement -- dwindle never looks
		-- at the mouse position to decide where a new window lands, only
		-- which window is focused. 0 restores Hyprland's own default: split
		-- direction follows the focused window's aspect ratio instead of
		-- always going bottom/right. Changed 2026-10-09.
		force_split = 0,
	},
})

-- The old config also had `blurls = waybar`. That is no longer needed: HyDE
-- ships a layer rule named hyde_layer_blur in
-- ~/.local/share/hypr/lua/layer_rules.lua which already blurs the waybar layer.

-- SUPER + T opened kitty straight into fullscreen every time (2026-10-08).
-- hyprctl's own client JSON pinned it down: the new window reported
-- fullscreenClient = 1, Hyprland's marker for "the client itself asked for
-- this", not fullscreen = 1 from a Hyprland-side rule or layout decision.
-- Confirmed live, twice, by watching `hyprctl clients -j` the instant the
-- window appeared.
--
-- The request traces to how SUPER + T launches kitty, not to kitty.conf
-- (checked, no fullscreen/start_as directive) or to dwindle (a plain `kitty &`
-- from a shell never reproduces it, every time). The bind runs
-- `hyde-shell app -T`, which execs into app2unit, which launches via
-- `systemd-run --user --scope` through xdg-terminal-exec. Every other app
-- keybind (SUPER + E for Dolphin, etc.) goes through hyde-shell's plainer
-- `open` path instead and never shows this. None of the three scripts in
-- that chain (app.sh, app2unit, xdg-terminal-exec) mention fullscreen
-- anywhere, so whatever sets this request happens inside systemd-run's scope
-- launch or xdg-terminal-exec's activation handling, not in a line of shell
-- that can be pointed at directly.
--
-- Rather than chase that interaction further, this suppresses the request at
-- the one place Hyprland is built to do exactly that: a static window rule
-- matching on initialClass, since the rule fires before the client's first
-- fullscreen request is ever honoured.
--
-- First attempt only suppressed "fullscreen" and did not fix it (confirmed on
-- video). SUPER + F's own toggle_fullscreen in hyprland.lua flips between
-- state 0 and state 2 (maximize), not 1, so the request was maximize even
-- though the captured JSON read "fullscreen":1. Suppressing both events
-- together, confirmed fixed 2026-10-08.
hl.window_rule({
	name = "kitty-no-autofullscreen",
	match = { class = "^(kitty)$" },
	suppress_event = "fullscreen maximize",
})
