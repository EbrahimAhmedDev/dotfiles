#!/usr/bin/env bash
# Power profile picker — choose performance / balanced / power-saver
# (used by the waybar battery click and the control menu)

command -v powerprofilesctl >/dev/null 2>&1 || exit 1
current=$(powerprofilesctl get 2>/dev/null || echo balanced)

choice=$(printf '%s\n' performance balanced power-saver \
    | rofi -dmenu -i -p "Power Profile (now: $current)") || exit 0

case "$choice" in
    performance|balanced|power-saver)
        powerprofilesctl set "$choice" && notify-send "Power Profile" "$choice ✓"
        ;;
esac
