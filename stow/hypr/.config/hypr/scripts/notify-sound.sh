#!/usr/bin/env bash
# Notification sound player — used by the swaync script (and manual testing).
# Volume is independent from the system volume: edit ~/.config/hypr/sounds.conf

conf="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/sounds.conf"
[ -f "$conf" ] && . "$conf"

vol="${SND_VOLUME:-0.6}"
file="/usr/share/sounds/ocean/stereo/message-new-instant.oga"

command -v pw-play >/dev/null 2>&1 && [ -f "$file" ] \
    && pw-play --volume "$vol" "$file" >/dev/null 2>&1 &
