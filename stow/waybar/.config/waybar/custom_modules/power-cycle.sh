#!/usr/bin/env bash

current=$(powerprofilesctl get)

case "$current" in
  "power-saver")
    next="balanced"
    label="Balanced ⚖️"
    ;;
  "balanced")
    if powerprofilesctl list | grep -q "performance"; then
      next="performance"
      label="Performance 🚀"
    else
      next="power-saver"
      label="Power Saver 🔋"
    fi
    ;;
  "performance")
    next="power-saver"
    label="Power Saver 🔋"
    ;;
  *)
    next="balanced"
    label="Balanced ⚖️"
    ;;
esac

powerprofilesctl set "$next"
notify-send -u low -t 2000 "Power Profile" "Switched to: $label"
pkill -RTMIN+8 waybar
