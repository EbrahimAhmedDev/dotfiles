#!/usr/bin/env bash
# Show a SwayOSD popup when the keyboard layout changes.
# Listens to Hyprland's event socket, so Win+Space keeps working as-is.
set -u

[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || exit 0

runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
sock="$runtime/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# Autostart can fire before Hyprland creates its event socket: wait for it.
for _ in $(seq 60); do
    [ -S "$sock" ] && break
    sleep 0.5
done
[ -S "$sock" ] || exit 0

# The physical keyboard, not the virtual power/sleep/button devices.
find_kbd() {
    hyprctl devices -j 2>/dev/null | jq -r '.keyboards[].name' \
        | grep -viE 'button|video-bus|power|sleep' | head -n1
}

kbd=""
for _ in $(seq 20); do
    kbd=$(find_kbd)
    [ -n "$kbd" ] && break
    sleep 0.5
done
[ -n "$kbd" ] || exit 0

# Reconnect if the socket goes away (e.g. Hyprland reload).
while [ -S "$sock" ]; do
    socat -U - "UNIX-CONNECT:$sock" | while IFS= read -r line; do
        case "$line" in
            "activelayout>>$kbd,"*)
                layout="${line#*,}"
                case "$layout" in
                    *Arabic*) msg="AR 🇪🇬" ;;
                    *English*) msg="EN 🇺🇸" ;;
                    *) msg="$layout" ;;
                esac
                swayosd-client --custom-message "$msg" --custom-icon input-keyboard
                ;;
        esac
    done
    sleep 1
done
