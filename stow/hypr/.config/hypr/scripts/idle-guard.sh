#!/usr/bin/env bash
# idle-guard.sh — keep the machine awake while a game is running.
#
# Exit 0 → idle actions (dim, lock, dpms, suspend) are allowed.
# Exit 1 → a game is active, so hypridle must skip the action.
#
# Used from hypridle.conf like this:
#   on-timeout = ~/.config/hypr/scripts/idle-guard.sh && loginctl lock-session
#
# A game counts as active when:
#   * a window is fullscreen (fullscreen 2 or 3 in `hyprctl clients`), or
#   * a Wine/Proton/gamescope process is running (covers windowed games).

set -u

# Wine / Proton / gamescope game processes
if pgrep -f '(^|/)(wine|wine64|wine-preloader|wine64-preloader|wineserver|proton|gamescope)( |$)|\.exe( |$)' >/dev/null 2>&1; then
    exit 1
fi

# Fullscreen window (2 = fullscreen, 3 = fullscreen + maximized)
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl clients -j 2>/dev/null | python3 -c '
import json, sys
try:
    clients = json.load(sys.stdin)
except Exception:
    sys.exit(1)
sys.exit(0 if any((c.get("fullscreen") or 0) >= 2 for c in clients) else 1)
' && exit 1
fi

exit 0
