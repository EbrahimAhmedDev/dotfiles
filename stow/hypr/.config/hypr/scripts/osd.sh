#!/usr/bin/env bash
# Volume / brightness OSD (SwayOSD) + ThinkPad mute-LED sync.
# PipeWire doesn't sync the keyboard mute LEDs like PulseAudio did,
# so we sync them ourselves after every mute toggle (see system/udev/).

LED="/sys/class/leds"

sync_led() { # sync_led <led> <0|1>
    [ -w "$LED/$1/brightness" ] && echo "$2" > "$LED/$1/brightness"
}

# --- click sounds (KDE Ocean theme, played via pw-play) ---
SND_DIR="/usr/share/sounds/ocean/stereo"
_sndconf="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/sounds.conf"
[ -f "$_sndconf" ] && . "$_sndconf"
SND_VOLUME="${SND_VOLUME:-0.6}"
play_sound() { # play_sound <file.oga> — throttled so key-repeat doesn't spam
    [ -f "$1" ] || return 0
    command -v pw-play >/dev/null 2>&1 || return 0
    now=$(date +%s%N)
    _tsf="${XDG_RUNTIME_DIR:-/tmp}/osd-sound.ts"
    if [ -f "$_tsf" ]; then
        prev=$(cat "$_tsf")
        [ $(( (now - prev) / 1000000 )) -lt 150 ] && return 0
    fi
    echo "$now" > "$_tsf"
    pw-play --volume "$SND_VOLUME" "$1" >/dev/null 2>&1 &
}

# --- OSD + actual change (SwayOSD) ---
case "$1" in
    vol-up)      swayosd-client --output-volume +5 ; play_sound "$SND_DIR/audio-volume-change.oga" ;;
    vol-down)    swayosd-client --output-volume -5 ; play_sound "$SND_DIR/audio-volume-change.oga" ;;
    mute)        swayosd-client --output-volume mute-toggle ;;
    mic-mute)    swayosd-client --input-volume mute-toggle ;;
    bright-up)   swayosd-client --brightness +5 ;;
    bright-down) swayosd-client --brightness -5 ;;
    *) exit 1 ;;
esac

# --- mute LEDs ---
case "$1" in
    mute)
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
            sync_led "platform::mute" 1
        else
            sync_led "platform::mute" 0
        fi
        ;;
    mic-mute)
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            sync_led "platform::micmute" 1
        else
            sync_led "platform::micmute" 0
        fi
        ;;
esac
