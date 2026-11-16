#!/usr/bin/env bash
# Apply a theme: waybar colors + wob colors + wallpaper.
# Usage: theme.sh [name]   (من غير اسم = قائمة rofi)
# Theme files live in ~/dotfiles/themes/<name>/ (theme.css + theme.env + optional wallpaper)

set -u

THEMES_DIR="$HOME/dotfiles/themes"
WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
WP_DIR="$HOME/Pictures/wallpapers"

if [ -z "${1:-}" ]; then
    name=$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort \
        | rofi -dmenu -i -p "🎨 الثيم") || exit 0
else
    name="$1"
fi

if [ -z "$name" ] || [ ! -d "$THEMES_DIR/$name" ]; then
    notify-send -u critical "🎨 الثيم" "مش لاقي الثيم: ${name:-فاضي}"
    exit 1
fi
src="$THEMES_DIR/$name"

# 1) ألوان waybar
cp "$src/theme.css" "$WAYBAR_DIR/theme.css"

# 2) ألوان wob/OSD (osd.sh بيقرا theme.env)
cp "$src/theme.env" "$HYPR_DIR/theme.env"

# 3) الوولبر (اختياري لكل ثيم)
wp=$(ls "$src"/wallpaper.* 2>/dev/null | head -1)
if [ -n "$wp" ]; then
    dest="$WP_DIR/theme-${name}.${wp##*.}"
    cp -f "$wp" "$dest"
    awww img "$dest" >/dev/null 2>&1
    # waypaper بيرجّع آخر وولبرا عند البداية، فنحدّث سطره
    wpconf="$HOME/.config/waypaper/config.ini"
    [ -f "$wpconf" ] && sed -i "s|^wallpaper = .*|wallpaper = $dest|" "$wpconf"
fi

# 4) إعادة تشغيل waybar عشان ياخد الألوان الجديدة
pkill -x waybar 2>/dev/null
sleep 0.4
setsid -f waybar >/dev/null 2>&1

notify-send "🎨 الثيم" "\"$name\" اتفعل ✅"
