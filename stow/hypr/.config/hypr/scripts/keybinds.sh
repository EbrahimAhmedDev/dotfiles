#!/usr/bin/env bash
# Keybinds cheat sheet — rofi overlay listing every shortcut with a short
# explanation. Opens with SUPER + N.
# UI text is English by design.

menu=$(cat <<'EOF'
──  Apps & Launchers  ──
SUPER + T .................... Terminal (Ghostty)
SUPER + B .................... Web browser (Chrome)
SUPER + M .................... Music (Spotify)
SUPER + SHIFT + F ............ File manager (Dolphin)
SUPER + S .................... App launcher (rofi)
SUPER + SHIFT + S ............ Run a command (rofi)
SUPER + CTRL + S ............. Control menu (themes, OCR, update, power…)
SUPER + SHIFT + O ............ Extract text from screen (OCR)
SUPER + V .................... Clipboard history (clipse)

──  Windows & Session  ──
SUPER + Q .................... Close focused window
SUPER + F .................... Fullscreen toggle
SUPER + SHIFT + T ............ Floating window toggle
SUPER + L .................... Lock screen
SUPER + P .................... Power menu (logout / sleep / reboot / off)
SUPER + CTRL + Q ............. Log out of Hyprland

──  Focus, Move & Resize  ──
SUPER + Arrow keys ........... Focus window
SUPER + SHIFT + Arrows ....... Move window
SUPER + CTRL + Arrows ........ Resize window
SUPER + CTRL + R ............. Reset split ratio to 50/50
SUPER + Left mouse drag ...... Move floating window
SUPER + Right mouse drag ..... Resize floating window

──  Workspaces  ──
SUPER + 1-9 .................. Switch to workspace
SUPER + SHIFT + 1-9 .......... Move window to workspace

──  Volume & Media (works even when locked)  ──
Volume Up / Down ............. Change volume (OSD + click sound)
Mute ......................... Mute / unmute audio
Mic mute ..................... Mute / unmute microphone
Brightness Up / Down ......... Screen brightness
Play / Next / Prev ........... Media player control

──  Screenshots  ──
Print ....................... Select area → annotate (Satty)
SHIFT + Print ................ Full screenshot
SUPER + Print ............... Start / stop screen recording (Kooha)

──  Utilities  ──
SUPER + N .................... This cheat sheet
SUPER + SHIFT + C ............ Color picker (copies the color)
Fn + F9 ...................... Hyprmod quick launcher
EOF
)

printf '%s\n' "$menu" | rofi -dmenu -i -p "Keybinds" \
    -mesg "All shortcuts on this system — Esc to close"
