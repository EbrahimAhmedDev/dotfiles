#!/usr/bin/env bash
# Central control menu — كل إعدادات النظام من مكان واحد (زي Omarchy menu)
# مفتوحة بـ SUPER + CTRL + S

choice=$(rofi -dmenu -i -p "🎛️ التحكم" <<'EOF'
🌐  الاتصالات (Wi-Fi)
🔵  البلوتوث
🎚️  الصوت (Mixer)
🔋  بروفايل الطاقة
🎨  تبديل الثيم
🖼️  الوولبر
🔄  تحديث النظام
🌙  الوضع الليلي
📋  الكليبورد
🔒  قفل الشاشة
⏻  الطاقة / خروج
ℹ️  About
EOF
) || exit 0

scripts="$HOME/.config/hypr/scripts"

case "$choice" in
    *الاتصالات*)  exec nmrs-gui ;;
    *البلوتوث*)   exec blueman-manager ;;
    *الصوت*)      exec pavucontrol ;;
    *بروفايل*)    exec "$HOME/.config/waybar/custom_modules/power-cycle.sh" ;;
    *الثيم*)      exec "$scripts/theme.sh" ;;
    *الوولبر*)    exec waypaper ;;
    *تحديث*)      exec ghostty -e "$HOME/dotfiles/scripts/dotupdate.sh" ;;
    *الليلي*)     exec "$scripts/nightlight.sh" ;;
    *الكليبورد*)  exec ghostty --class=com.clipse.tui --gtk-single-instance=false -e clipse ;;
    *قفل*)        exec loginctl lock-session ;;
    *الطاقة*)     exec wlogout ;;
    *About*)      exec ghostty -e fastfetch ;;
esac
