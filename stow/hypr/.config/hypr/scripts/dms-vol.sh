#!/usr/bin/env bash
# Dux Shell (DMS) volume wrapper — uses DMS audio IPC but keeps the user's
# click sound (independent volume via ~/.config/hypr/sounds.conf).
set -u

conf="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/sounds.conf"
[ -f "$conf" ] && . "$conf"
SND_VOLUME="${SND_VOLUME:-0.6}"
snd="/usr/share/sounds/ocean/stereo/audio-volume-change.oga"

click() {
    command -v pw-play >/dev/null 2>&1 || return 0
    [ -f "$snd" ] || return 0
    now=$(date +%s%N)
    _tsf="${XDG_RUNTIME_DIR:-/tmp}/dms-vol.ts"
    if [ -f "$_tsf" ]; then
        prev=$(cat "$_tsf")
        [ $(( (now - prev) / 1000000 )) -lt 150 ] && return 0
    fi
    echo "$now" > "$_tsf"
    pw-play --volume "$SND_VOLUME" "$snd" >/dev/null 2>&1 &
}

case "$1" in
    up)    click; dms ipc call audio increment 5 ;;
    down)  click; dms ipc call audio decrement 5 ;;
    mute)  dms ipc call audio mute ;;
    mic)   dms ipc call mic mute ;;
    *) exit 1 ;;
esac
