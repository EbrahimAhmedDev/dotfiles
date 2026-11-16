hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,
        border_size = 2,
        layout = "dwindle",
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(8f00ffee)" }, angle = 45 },
            inactive_border = "rgba(44415aaa)",
        },
    },
    decoration = {
        rounding = 8,
        inactive_opacity = 0.85,
        blur = {
            enabled = false,
        },
    },
    input = {
        kb_layout = "us,ara",
        kb_options = "grp:win_space_toggle",
        repeat_rate = 25,
        repeat_delay = 300,
        touchpad = {
            scroll_factor = 0.4,
            natural_scroll = true,
        },
    },
    dwindle = {
        preserve_split = true,
    },
})
