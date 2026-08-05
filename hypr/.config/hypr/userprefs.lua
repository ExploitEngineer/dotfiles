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
})

-- The old config also had `blurls = waybar`. That is no longer needed: HyDE
-- ships a layer rule named hyde_layer_blur in
-- ~/.local/share/hypr/lua/layer_rules.lua which already blurs the waybar layer.

-- ── Floating centred terminal ───────────────────────────────────────────────
-- Matched on a dedicated window class rather than "kitty", so ordinary
-- terminals keep tiling normally. The launcher for it is SUPER+CTRL+T in
-- keybindings.lua, which starts kitty with --class floatterm.
hl.window_rule({
	name = "floating_terminal",
	match = {class = "floatterm"},
	float = true,
	center = true,
	size = "(monitor_w*0.6) (monitor_h*0.6)",
})
