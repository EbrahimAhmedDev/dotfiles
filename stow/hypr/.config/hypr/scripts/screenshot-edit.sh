#!/usr/bin/env bash
# Select an area (screen frozen during selection), then edit it in Satty.
# Saved to ~/Pictures/Screenshots and copied to the clipboard.

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

# Freeze the screen while selecting
hyprpicker -r -z >/dev/null 2>&1 &
freeze_pid=$!
sleep 0.3

geom=$(slurp)
if [ -z "$geom" ]; then
    kill "$freeze_pid" 2>/dev/null
    exit 0
fi

tmp=$(mktemp --suffix=.png)
grim -g "$geom" "$tmp"
kill "$freeze_pid" 2>/dev/null

satty --filename "$tmp" \
    --output-filename "$dir/screenshot-$(date +%Y%m%d-%H%M%S).png" \
    --copy-command wl-copy \
    --early-exit

rm -f "$tmp"
