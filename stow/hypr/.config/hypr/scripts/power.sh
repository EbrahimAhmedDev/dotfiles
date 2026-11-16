#!/usr/bin/env bash

choice=$(printf "Lock\nSuspend\nLogout\nReboot\nShutdown" | rofi -dmenu -i -p "Power") || exit 0
case "$choice" in
    Lock)     loginctl lock-session ;;
    Suspend)  systemctl suspend ;;
    Logout)   loginctl terminate-user "$USER" ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
