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

-- Per-theme blur strength. Because this file overrides whatever the theme set,
-- editing a theme's own hypr.theme has no effect; the override has to happen
-- here instead. `passes` drives most of the visible strength, `size` widens the
-- sample radius.
--
-- The active theme name comes from hyde.config.ui.hyde_theme, which dynamic.lua
-- populates from lua_state/ui.lua before hyprland.lua is loaded.
local per_theme = {
	["Red Stone"] = { size = 8, passes = 4 },
}

local theme = (hyde.config.ui or {}).hyde_theme
for k, v in pairs(per_theme[theme] or {}) do
	blur[k] = v
end

hl.config({
	decoration = {
		-- Opacity is the reason blur looked absent on some themes, not the blur
		-- settings themselves. Blur is enabled by all 43 themes, but several set
		-- active_opacity = 1, which makes the focused window fully opaque so the
		-- blurred content behind it cannot be shown. Crimson-Blue sets both
		-- opacities to 1 and xray = true, which removes it entirely.
		--
		-- These are HyDE's own defaults, pinned here so themes cannot raise them
		-- back to 1. Remove these two lines if you would rather let each theme
		-- decide.
		active_opacity = 0.90,
		inactive_opacity = 0.75,

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
