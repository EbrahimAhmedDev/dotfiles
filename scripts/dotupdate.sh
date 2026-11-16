#!/usr/bin/env bash
# Unified update: repos + AUR + pacman cache cleanup.
# Run from a terminal: dotupdate   (or from the control menu SUPER+CTRL+S)

echo "🔄 Unified Update"
echo "══════════════════"
echo
echo "⏳ Checking for updates..."

repos=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)
total=$((repos + aur))

if [ "$total" -eq 0 ]; then
    echo "✅ No updates available — system is fully up to date."
    notify-send "Update" "No updates available ✓"
    read -rn1 -k "?Press any key to close..."
    exit 0
fi

echo "📦 Available: $repos from repos + $aur from AUR ($total total)"
echo "────────────────────────────"
checkupdates 2>/dev/null | head -20
[ "$aur" -gt 0 ] && echo "... + $aur packages from AUR"
echo "────────────────────────────"
echo
read -rp "Run the full update? [y/N] " answer
case "$answer" in [yY]*) ;; *) echo "Cancelled."; exit 0 ;; esac

if yay -Syu; then
    echo
    echo "🧹 Cleaning pacman cache (keeping the last version per package)..."
    sudo paccache -rk1 2>/dev/null || true
    notify-send "Update" "Finished successfully ✓"
    echo "✅ Update finished."
else
    notify-send -u critical "Update" "Update failed ✗ (check the errors above)"
    echo "❌ Update failed — check the errors above."
fi
read -rn1 -k "?Press any key to close..."
