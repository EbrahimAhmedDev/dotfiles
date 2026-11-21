local function floating(name, match, width, height)
    local rule = { name = name, match = match, float = true, center = true }
    if width and height then
        rule.size = { width, height }
    end
    hl.window_rule(rule)
end

floating("waypaper-floating", { class = "waypaper" }, 800, 550)
floating("pavucontrol-floating", { class = "org.pulseaudio.pavucontrol" }, 800, 500)
floating("blueman-floating", { class = "blueman-manager" }, 750, 500)
floating("nm-editor-floating", { class = "nm-connection-editor" }, 750, 500)
floating("nmrs-floating", { class = "(?i).*nmrs.*" }, 780, 520)
floating("monitors-floating", { title = "^(btop|htop|nmtui|pulsemixer)$" }, 820, 510)
floating("satty-floating", { class = "com.gabm.satty" }, 800, 600)

-- Distinct outline for every floating window so they are recognizable
hl.window_rule({
    name = "floating-outline",
    match = { float = true },
    border_color = "rgba(ff7a00ff)", -- orange
})
