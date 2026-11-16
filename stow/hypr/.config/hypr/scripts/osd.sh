#!/usr/bin/env bash



WOB="$XDG_RUNTIME_DIR/wob.sock"
BG="18181bee"

case "$1" in
    vol-up)      wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    vol-down)    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute)        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    bright-up)   brightnessctl -q set 5%+ ;;
    bright-down) brightnessctl -q set 5%- ;;
    *) exit 1 ;;
esac

[ -p "$WOB" ] || exit 0

case "$1" in
    vol-*|mute)
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
            echo "0 $BG ff5252 ff5252" > "$WOB"
        else
            v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100 + 0.5)}')
            echo "$v $BG b388ff b388ff" > "$WOB"
        fi
        ;;
    bright-*)
        b=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
        echo "$b $BG ffd54f ffd54f" > "$WOB"
        ;;
esac
