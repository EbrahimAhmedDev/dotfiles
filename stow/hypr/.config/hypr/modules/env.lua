-- Use Qt6ct, not Plasma integration, so Qt apps follow theme-generator palettes.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_DATA_DIRS",
    "/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:" ..
    os.getenv("HOME") .. "/.local/share/flatpak/exports/share") -- for flatpak apps
