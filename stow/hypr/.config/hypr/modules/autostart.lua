hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("clipse -listen")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("udiskie --no-tray")

    -- Wallpaper: waypaper starts its own daemon and restores the last wallpaper
    hl.exec_cmd([[sh -c "sleep 1; waypaper --restore"]])

    -- On-screen bar for volume and brightness (wob reads from a fifo)
    hl.exec_cmd(
        [[sh -c 'rm -f "$XDG_RUNTIME_DIR/wob.sock"; mkfifo "$XDG_RUNTIME_DIR/wob.sock"; tail -f "$XDG_RUNTIME_DIR/wob.sock" | wob']])
end)
