hl.on("hyprland.start", function()
    -- Dux Shell (DMS): bar + notifications + launcher + clipboard + control center
    hl.exec_cmd("dms run")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("udiskie --no-tray")

    -- NOTE (dux-shell trial): waybar / swaync / wob / waypaper / clipse are NOT
    -- started — DMS covers all of them (bar, notification center, OSD,
    -- wallpaper, clipboard manager). Their configs stay in the repo unused.
end)
