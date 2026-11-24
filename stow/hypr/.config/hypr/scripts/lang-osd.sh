#!/usr/bin/env bash
# Show a SwayOSD popup when the keyboard layout changes.
# Listens to Hyprland's event socket, so Win+Space keeps working as-is.
set -u

[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || exit 0
sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
[ -S "$sock" ] || exit 0

# The physical keyboard, not the virtual power/sleep/button devices.
kbd=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[].name' \
    | grep -viE 'button|video-bus|power|sleep' | head -n1)
[ -n "$kbd" ] || kbd=$(hyprctl devices -j 2>/dev/null \
    | jq -r '.keyboards[] | select(.main) | .name' | head -n1)
[ -n "$kbd" ] || exit 0

socat -U - "UNIX-CONNECT:$sock" | while IFS= read -r line; do
    case "$line" in
        "activelayout>>$kbd,"*)
            layout="${line#*,}"
            case "$layout" in
                *Arabic*) msg="AR" ;;
                *English*) msg="EN" ;;
                *) msg="$layout" ;;
            esac
            swayosd-client --custom-message "$msg" --custom-icon input-keyboard
            ;;
    esac
done
