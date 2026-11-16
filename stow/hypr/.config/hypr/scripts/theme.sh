#!/usr/bin/env bash
# Apply a theme: waybar colors + wob colors + wallpaper + GTK light/dark for apps.
# Usage: theme.sh [name]   (no name = rofi picker)
# Theme files live in ~/dotfiles/themes/<name>/ :
#   theme.css    - waybar colors
#   theme.env    - wob/OSD colors
#   theme.conf   - optional, "mode=dark" or "mode=light" (controls app/GTK theme)
#   wallpaper.*  - optional wallpaper

set -u

THEMES_DIR="$HOME/dotfiles/themes"
WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
GTK4_INI="$HOME/.config/gtk-4.0/settings.ini"
XSET_CONF="$HOME/.config/xsettingsd/xsettingsd.conf"
WP_DIR="$HOME/Pictures/wallpapers"

if [ -z "${1:-}" ]; then
    name=$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort \
        | rofi -dmenu -i -p "Theme") || exit 0
else
    name="$1"
fi

if [ -z "$name" ] || [ ! -d "$THEMES_DIR/$name" ]; then
    notify-send -u critical "Theme" "Not found: ${name:-<none>}"
    exit 1
fi
src="$THEMES_DIR/$name"

# 1) waybar colors
cp "$src/theme.css" "$WAYBAR_DIR/theme.css"

# 2) wob/OSD colors (osd.sh sources theme.env)
cp "$src/theme.env" "$HYPR_DIR/theme.env"

# 3) wallpaper (optional per theme)
wp=$(ls "$src"/wallpaper.* 2>/dev/null | head -1)
if [ -n "$wp" ]; then
    dest="$WP_DIR/theme-${name}.${wp##*.}"
    cp -f "$wp" "$dest"
    awww img "$dest" >/dev/null 2>&1
    # waypaper restores the last wallpaper at login, so update its line too
    wpconf="$HOME/.config/waypaper/config.ini"
    [ -f "$wpconf" ] && sed -i "s|^wallpaper = .*|wallpaper = $dest|" "$wpconf"
fi

# 4) App theme (GTK): declared as mode=dark|light in theme.conf
mode="dark"
[ -f "$src/theme.conf" ] && mode=$(grep '^mode=' "$src/theme.conf" | cut -d= -f2 | tr -d '[:space:]')

if command -v xsettingsd >/dev/null 2>&1 && [ -f "$XSET_CONF" ]; then
    if [ "$mode" = "light" ]; then
        xset_name="Breeze";       pref="false"; scheme="default"
    else
        xset_name="Breeze-Dark";  pref="true";  scheme="prefer-dark"
    fi
    sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$pref/" \
        "$GTK3_INI" "$GTK4_INI" 2>/dev/null
    sed -i "s/^Net\/ThemeName .*/Net\/ThemeName \"$xset_name\"/" "$XSET_CONF"
    gsettings set org.gnome.desktop.interface color-scheme "$scheme" 2>/dev/null
    # restart xsettingsd only if it was already running (it isn't on this setup)
    if pgrep -x xsettingsd >/dev/null 2>&1; then
        pkill -x xsettingsd
        setsid -f xsettingsd >/dev/null 2>&1
    fi
fi

# 5) restart waybar so it picks up the new colors
pkill -x waybar 2>/dev/null
sleep 0.4
setsid -f waybar >/dev/null 2>&1

notify-send "Theme" "\"$name\" applied (apps: $mode) ✓"
