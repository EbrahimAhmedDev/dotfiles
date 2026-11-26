hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("clipse -listen")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("udiskie --no-tray")

    -- Media: lets waybar's mpris module follow the active player (single daemon)
    hl.exec_cmd([[sh -c 'pgrep -x playerctld >/dev/null || playerctld']])

    -- Wallpaper: waypaper starts its own daemon and restores the last wallpaper
    hl.exec_cmd([[sh -c "sleep 1; waypaper --restore"]])

    -- If the user selected Glass Amber, re-derive it from the wallpaper at login.
    hl.exec_cmd([[sh -c 'sleep 2; theme_name=$(cat "$HOME/.config/hypr/theme.name" 2>/dev/null || true); if [ "$theme_name" = "glass-amber" ]; then "$HOME/.config/hypr/scripts/theme.sh" glass-amber; fi']])

    -- On-screen display for volume, brightness and lock keys (SwayOSD)
    hl.exec_cmd([[sh -c 'pgrep -x swayosd-server >/dev/null || swayosd-server']])

    -- OSD for keyboard layout changes
    hl.exec_cmd([[sh -c 'pgrep -f "^bash .*[l]ang-osd[.]sh$" >/dev/null || "$HOME/.config/hypr/scripts/lang-osd.sh"']])
end)
