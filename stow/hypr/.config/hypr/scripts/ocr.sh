#!/usr/bin/env bash
# OCR: تحدد جزء من الشاشة → استخراج النص (عربي + إنجليزي) → الكليبورد
# مفتوحة بـ SUPER + SHIFT + O

set -u

if ! command -v tesseract >/dev/null 2>&1; then
    notify-send -u critical "📷 OCR" "tesseract مش متثبت.\nثبته:\nsudo pacman -S tesseract tesseract-data-eng tesseract-data-ara"
    exit 1
fi

# تجميد الشاشة أثناء التحديد (نفس أسلوب screenshot-edit.sh)
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

text=$(tesseract "$tmp" - -l eng+ara --psm 3 2>/dev/null | sed '/^[[:space:]]*$/d')
rm -f "$tmp"

if [ -z "$text" ]; then
    notify-send "📷 OCR" "مفيش نص اتلقط"
    exit 0
fi

printf '%s' "$text" | wl-copy
notify-send "📷 OCR" "النص اتنسخ للكليبورد ✅"
