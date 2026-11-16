#!/usr/bin/env bash
# Night light: toggle
if pgrep -x hyprsunset >/dev/null; then
    pkill -x hyprsunset
    notify-send "Night light" "Off"
else
    nohup hyprsunset -t 4500 >/dev/null 2>&1 &
    notify-send "Night light" "On"
fi
