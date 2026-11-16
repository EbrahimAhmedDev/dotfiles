#!/usr/bin/env bash
# Screenshot: saved to ~/Pictures/Screenshots and copied to the clipboard.
# Clicking the notification opens the file location.

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

case "$1" in
    area)
        geom=$(slurp) || exit 0
        grim -g "$geom" "$file"
        ;;
    full)
        grim "$file"
        ;;
    *)
        exit 1
        ;;
esac

wl-copy < "$file"

(
    action=$(notify-send -i "$file" -A "default=Open" "Screenshot taken" "$file")
    if [ "$action" = "default" ]; then
        dolphin --select "$file"
    fi
) >/dev/null 2>&1 &
