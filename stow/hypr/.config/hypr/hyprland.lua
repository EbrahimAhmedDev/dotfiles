-- ~/.config/hypr/hyprland.lua
-- Hyprland 0.55+ Lua config

package.path = os.getenv("HOME") .. "/.config/hypr/?.lua;" .. package.path


require("modules.monitor")
require("modules.env")
require("modules.autostart")
require("modules.appearance")
require("modules.keybinds")
require("modules.rules")

require("hyprland-gui")
