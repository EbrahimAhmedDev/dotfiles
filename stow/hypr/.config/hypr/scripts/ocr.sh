#!/usr/bin/env bash
# OCR + QR: select a screen area -> decode a QR/barcode or extract text -> clipboard
# Opens with SUPER + SHIFT + O

set -u

have_qr=0
have_ocr=0
command -v ZXingReader >/dev/null 2>&1 && have_qr=1
command -v tesseract >/dev/null 2>&1 && have_ocr=1

if [ "$have_qr" -eq 0 ] && [ "$have_ocr" -eq 0 ]; then
    notify-send -u critical "OCR / QR" "Install tesseract (text) or zxing-cpp (QR) first."
    exit 1
fi

# Freeze the screen while selecting (same approach as screenshot-edit.sh)
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

# QR / barcode first; a detected code is more reliable than OCR on the same pixels.
qr_text=""
if [ "$have_qr" -eq 1 ]; then
    qr_text=$(ZXingReader -single -bytes "$tmp" 2>/dev/null || true)
fi

text=""
if [ "$have_ocr" -eq 1 ]; then
    text=$(tesseract "$tmp" - -l eng+ara --psm 3 2>/dev/null | sed '/^[[:space:]]*$/d')
fi

rm -f "$tmp"

if [ -n "$qr_text" ]; then
    printf '%s' "$qr_text" | wl-copy
    preview=$(printf '%s' "$qr_text" | tr '\n\r' '  ')
    preview=${preview:0:160}
    message="Copied: $preview"
    [ -n "$text" ] && message="$message (text also detected)"
    notify-send "QR / Barcode" "$message"
    exit 0
fi

if [ -z "$text" ]; then
    if [ "$have_ocr" -eq 1 ]; then
        notify-send "OCR / QR" "No text or QR code detected"
    else
        notify-send "OCR / QR" "No QR code detected (text OCR is not installed)"
    fi
    exit 0
fi

printf '%s' "$text" | wl-copy
notify-send "OCR" "Text copied to clipboard ✓"
