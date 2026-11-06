# Dolphin



Dolphin stays the file manager, with HyDE's layout: Places and Information panels docked on the right and an icon-only toolbar.
Only two files differ from HyDE's shipped copies, and `dolphinui.rc` and the global view properties are left to HyDE.

`dolphinrc` adds `RememberOpenedTabs=false`.
With the default, Dolphin reopens every tab from the last session, which piled up a dozen tabs and kept the tab bar permanently on screen.
It also keeps HyDE's `ToolBarsMovable=Disabled`, which Dolphin drops when the toolbar is dragged, letting it drift out of the layout.

`.local/state/dolphinstaterc` is HyDE's window state with the Terminal panel hidden.
HyDE's state leaves that panel visible, but HyDE does not install Konsole, so the panel only ever shows "Terminal cannot be shown because Konsole is not installed".
The panel's visibility is a flag byte in the base64 `State=` blob, not a readable key, so it was toggled by editing that byte.

`kdeglobals` is not tracked: `color.set.sh` rewrites its colours on every theme switch.
