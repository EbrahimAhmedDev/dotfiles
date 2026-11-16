hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_DATA_DIRS",
    "/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:" ..
    os.getenv("HOME") .. "/.local/share/flatpak/exports/share") -- for flatpak apps
