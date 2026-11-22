#!/usr/bin/env bash
set -eu

notify-send "Default Apps" "Choose a category, then an app" 2>/dev/null || true

category=$(printf '%s\n' \
    'Text / Code' \
    'Browser / HTML' \
    'HTTP / HTTPS' \
    'Images' \
    'PDF' \
    'Folders / Files' \
    'Video' \
    'Audio' \
    'Magnet links' \
    | rofi -dmenu -i -p 'Default Apps') || exit 0
[ -n "$category" ] || exit 0

case "$category" in
    'Text / Code')       mime_filter='text/plain|text/x-|application/x-shellscript'; mimes='text/plain text/x-csrc text/x-python text/x-shellscript' ;;
    'Browser / HTML')    mime_filter='text/html'; mimes='text/html' ;;
    'HTTP / HTTPS')      mime_filter='x-scheme-handler/(http|https)'; mimes='x-scheme-handler/http x-scheme-handler/https' ;;
    'Images')            mime_filter='image/'; mimes='image/png image/jpeg image/gif image/webp image/svg+xml' ;;
    'PDF')               mime_filter='application/pdf'; mimes='application/pdf' ;;
    'Folders / Files')   mime_filter='inode/directory'; mimes='inode/directory' ;;
    'Video')             mime_filter='video/'; mimes='video/mp4 video/x-matroska video/webm video/quicktime' ;;
    'Audio')             mime_filter='audio/'; mimes='audio/mpeg audio/flac audio/ogg audio/x-wav' ;;
    'Magnet links')      mime_filter='x-scheme-handler/magnet'; mimes='x-scheme-handler/magnet' ;;
esac

current_app=$(for mime in $mimes; do xdg-mime query default "$mime" 2>/dev/null || true; done | sort -u | head -1)

pick_rows=''
row_names=()
row_desktop=()
row_icons=()
while IFS= read -r desk; do
    [ -r "$desk" ] || continue
    mime_types=$(sed -n 's/^MimeType=//p' "$desk" | head -1)
    if ! grep -Eiq "$mime_filter" <<<"$mime_types"; then
        continue
    fi

    hidden=$(sed -n 's/^Hidden=//p' "$desk" | head -1)
    no_display=$(sed -n 's/^NoDisplay=//p' "$desk" | head -1)
    [ "$hidden" = "true" ] || [ "$no_display" = "true" ] && continue

    name=$(sed -n 's/^Name=//p' "$desk" | head -1)
    icon=$(sed -n 's/^Icon=//p' "$desk" | head -1)
    desktop_name=$(basename "$desk")
    [ -n "$name" ] || continue

    if command -v gtk4-icon-browser >/dev/null 2>&1 && [ -n "$icon" ]; then
        :
    fi

    # Match SUPER+S: icon displayed by Rofi next to the application name.
    # Dedupe desktop entries by name and filename. Local/system entries may
    # use different IDs for the same app, and the local entry should be
    # preferred only when it is an actual override.
    normalized_name=${name,,}
    normalized_name=$(printf '%s' "$normalized_name" | sed 's/[[:space:]][[:space:]]*/ /g')
    for i in "${!row_names[@]}"; do
        existing_name=${row_names[$i],,}
        existing_name=$(printf '%s' "$existing_name" | sed 's/[[:space:]][[:space:]]*/ /g')
        if [ "$existing_name" = "$normalized_name" ]; then
            continue 2
        fi
    done

    row_names+=("$name")
    row_desktop+=("$desktop_name")
    row_icons+=("$icon")
    if [ -n "$icon" ]; then
        pick_rows+="$name\0icon\x1f$icon\n"
    else
        pick_rows+="$name\n"
    fi
done < <(find /usr/share/applications ~/.local/share/applications -maxdepth 1 -type f -name '*.desktop' 2>/dev/null)

[ -n "$pick_rows" ] || { notify-send "Default Apps" "No apps found for $category"; exit 1; }

# Put the current default at the top of the list.
if [ -n "${current_app:-}" ]; then
    for i in "${!row_desktop[@]}"; do
        if [ "${row_desktop[$i]}" = "$current_app" ]; then
            current_name=${row_names[$i]}
            current_icon=${row_icons[$i]:-}
            row_names=("$current_name" "${row_names[@]:0:$i}" "${row_names[@]:$((i+1))}")
            row_desktop=("$current_app" "${row_desktop[@]:0:$i}" "${row_desktop[@]:$((i+1))}")
            row_icons=("$current_icon" "${row_icons[@]:0:$i}" "${row_icons[@]:$((i+1))}")
            break
        fi
    done

    pick_rows=''
    for i in "${!row_names[@]}"; do
        if [ -n "${row_icons[$i]:-}" ]; then
            pick_rows+="${row_names[$i]}\0icon\x1f${row_icons[$i]}\n"
        else
            pick_rows+="${row_names[$i]}\n"
        fi
    done
fi

chosen=$(printf '%b' "$pick_rows" | rofi -dmenu -i -show-icons -format 's' -p "$category" -selected-row 0) || exit 0
[ -n "$chosen" ] || exit 0

name=""
desk_id=""
for i in "${!row_names[@]}"; do
    if [ "$chosen" = "${row_names[$i]}" ]; then
        name="${row_names[$i]}"
        desk_id="${row_desktop[$i]}"
        break
    fi
done
[ -n "$desk_id" ] || exit 1

for mime in $mimes; do
    xdg-mime default "$desk_id" "$mime"
done

notify-send "Default Apps" "$category -> $name"
