#!/usr/bin/env bash
# Central control menu — all system settings in one place (Omarchy-style menu)
# Opens with SUPER + CTRL + S

choice=$(rofi -dmenu -i -p "Control" <<'EOF'
🌐  Network (Wi-Fi)
🔵  Bluetooth
🎚️  Audio Mixer
🔋  Power Profile
🎨  Switch Theme
🖼️  Wallpaper
🔄  Update System
🌙  Night Light
📋  Clipboard
🔒  Lock Screen
⏻  Power / Logout
ℹ️  About
EOF
) || exit 0

scripts="$HOME/.config/hypr/scripts"

case "$choice" in
    *Network*)      exec nmrs-gui ;;
    *Bluetooth*)    exec blueman-manager ;;
    *Audio*)        exec pavucontrol ;;
    *Power*)        exec "$HOME/.config/waybar/custom_modules/power-picker.sh" ;;
    *Theme*)        exec "$scripts/theme.sh" ;;
    *Wallpaper*)    exec waypaper ;;
    *Update*)       exec ghostty -e "$HOME/dotfiles/scripts/dotupdate.sh" ;;
    *Night*)        exec "$scripts/nightlight.sh" ;;
    *Clipboard*)    exec ghostty --class=com.clipse.tui --gtk-single-instance=false -e clipse ;;
    *Lock*)         exec loginctl lock-session ;;
    *Logout*)       exec wlogout ;;
    *About*)        exec ghostty -e fastfetch ;;
esac
