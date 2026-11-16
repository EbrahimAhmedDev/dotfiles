#!/usr/bin/env bash
# Volume / brightness OSD (wob bar) + ThinkPad mute-LED sync.
# PipeWire doesn't sync the keyboard mute LEDs like PulseAudio did,
# so we sync them ourselves after every mute toggle (see system/udev/).

LED="/sys/class/leds"

sync_led() { # sync_led <led> <0|1>
    [ -w "$LED/$1/brightness" ] && echo "$2" > "$LED/$1/brightness"
}

WOB="$XDG_RUNTIME_DIR/wob.sock"

# Theme colors (written by theme.sh, see ~/dotfiles/themes/)
_tenv="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/theme.env"
[ -f "$_tenv" ] && . "$_tenv"
BG="${WOB_BG:-18181bee}"
VOL_COLOR="${WOB_VOL:-b388ff}"
MUTE_COLOR="${WOB_MUTE:-ff5252}"
BRIGHT_COLOR="${WOB_BRIGHT:-ffd54f}"

case "$1" in
    vol-up)      wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    vol-down)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute)        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic-mute)    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
    bright-up)   brightnessctl -q set 5%+ ;;
    bright-down) brightnessctl -q set 5%- ;;
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

[ -p "$WOB" ] || exit 0

case "$1" in
    vol-*|mute)
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
            echo "0 $BG $MUTE_COLOR $MUTE_COLOR" > "$WOB"
        else
            v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100 + 0.5)}')
            echo "$v $BG $VOL_COLOR $VOL_COLOR" > "$WOB"
        fi
        ;;
    mic-mute)
        if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
            echo "0 $BG $MUTE_COLOR $MUTE_COLOR" > "$WOB"
        else
            v=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print int($2 * 100 + 0.5)}')
            echo "$v $BG $VOL_COLOR $VOL_COLOR" > "$WOB"
        fi
        ;;
    bright-*)
        b=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
        echo "$b $BG $BRIGHT_COLOR $BRIGHT_COLOR" > "$WOB"
        ;;
esac
