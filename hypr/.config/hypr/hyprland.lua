-- User Configuration goeas here.
-- Adding keybinding are simple, refer to the wiki and add it here!
-- Duplicated keybinding will always respect the last last added, therefore please override keybindings as you wish.
--- use "require()" to load other lua files, for example:
-- require("keybindings") --- this will load "keybindings.lua"

-- Monitors.
-- Hyprland's built-in default is `,preferred,auto,auto`, and `auto` scale
-- resolves to 1.5 on this panel (1920x1080 @ 340x190mm), which shrinks the
-- usable desktop to 1280x720. Must be pinned to 1.0.
--
-- nwg-displays writes ~/.config/hypr/monitors.lua, but nothing in HyDE's lua
-- chain requires it - same trap the old monitors.conf fell into. Load it here
-- so the GUI actually takes effect, and fall back to a known-good rule if the
-- file is missing or broken.
if not pcall(require, "monitors") then
	hl.monitor({
		output   = "eDP-1",
		mode     = "preferred", -- 1920x1080@59.98, the only mode this panel advertises
		position = "0x0",
		scale    = 1.0,
	})
end

-- HyDE's defaults.lua sets input.numlock_by_default = true. On this ZBook the
-- embedded numpad overlay rides on numlock, so u/i/o/j/k/l/m/p type 4/5/6/1/2/3/0/*.
hl.config({
	input = {
		numlock_by_default = false,
	},
})

-- Brightness. This laptop never emits XF86MonBrightnessUp/Down (verified by
-- sweeping F1-F12: only volume and mic-mute keysyms arrive), so HyDE's stock
-- hardware binds can never fire. Bind to a combo that does reach the compositor.
hl.bind("SUPER + SHIFT + Up", hl.dsp.exec_cmd("hyde-shell brightnesscontrol -i"),
	{description = "[Hardware Controls|Brightness] increase brightness", repeating = true})
hl.bind("SUPER + SHIFT + Down", hl.dsp.exec_cmd("hyde-shell brightnesscontrol -d"),
	{description = "[Hardware Controls|Brightness] decrease brightness", repeating = true})

-- `fn` is consumed by the embedded controller and never reaches Hyprland, so it
-- cannot be bound directly. The function row is in HP "Action Keys" mode, which
-- means bare F3 emits XF86AudioMicMute while fn+F3 emits the *literal* F3
-- keysym. Binding literal F3/F4 therefore makes fn+F3 / fn+F4 control
-- brightness. Verified working on this machine.
-- Cost: this shadows bare F3/F4 in every application (browser find-next, etc.).
hl.bind("F3", hl.dsp.exec_cmd("hyde-shell brightnesscontrol -d"),
	{description = "[Hardware Controls|Brightness] decrease brightness (fn+F3)", repeating = true})
hl.bind("F4", hl.dsp.exec_cmd("hyde-shell brightnesscontrol -i"),
	{description = "[Hardware Controls|Brightness] increase brightness (fn+F4)", repeating = true})

-- Personal binds recovered from the pre-Lua ~/.config/hypr/keybindings.conf,
-- which HyDE stopped reading when the update moved to Lua mode.
-- HyDE ships only SUPER+CTRL+Left/Right for this; these are the vim-key variants.
hl.bind("SUPER + CTRL + H", hl.dsp.group.prev(),
	{description = "[Window Management|Group Navigation] change active group backwards"})
hl.bind("SUPER + CTRL + L", hl.dsp.group.next(),
	{description = "[Window Management|Group Navigation] change active group forwards"})
