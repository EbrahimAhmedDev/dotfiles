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
🧩  Default Apps
🌙  Night Light
📋  Clipboard
✂️  Extract Text / QR from Screen
🔒  Lock Screen
⏻  Power Menu
⌨  Keybinds
ℹ️  About
EOF
) || exit 0

scripts="$HOME/.config/hypr/scripts"

case "$choice" in
    *Network*)      exec nmrs-gui ;;
    *Bluetooth*)    exec blueman-manager ;;
    *Audio*)        exec pavucontrol ;;
    *Profile*)      exec "$HOME/.config/waybar/custom_modules/power-picker.sh" ;;
    *Theme*)        exec "$scripts/theme.sh" ;;
    *Wallpaper*)    exec waypaper ;;
    *Update*)       exec ghostty -e "$HOME/dotfiles/scripts/dotupdate.sh" ;;
    *Apps*)         exec "$HOME/.config/hypr/scripts/default-apps.sh" ;;
    *Night*)        exec "$scripts/nightlight.sh" ;;
    *Clipboard*)    exec ghostty --class=com.clipse.tui --gtk-single-instance=false -e clipse ;;
    *Extract*|*OCR*) exec "$scripts/ocr.sh" ;;
    *Lock*)         exec loginctl lock-session ;;
    *Power*|*Logout*) exec wlogout ;;
    *Keybind*)      exec "$scripts/keybinds.sh" ;;
    *About*)        exec ghostty -e bash -c 'fastfetch; echo; read -rsn1 -p "Press any key to close..."' ;;
esac
