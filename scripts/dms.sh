#!/usr/bin/env bash
# dms.sh — switch between the main setup and the Dux Shell (DMS) trial branch.
# Usage:
#   ./scripts/dms.sh try    → switch to DMS (live, no logout needed)
#   ./scripts/dms.sh back   → back to main setup (live, no logout needed)
# All UI text in English by design.

set -u
cd "$(dirname "$0")/.." || exit 1   # always run from the repo root

state_commit() { # commit live-state files so branch switching never conflicts
    if [ -n "$(git status --porcelain)" ]; then
        git add -A && git commit -q -m "live state before dms.sh switch"
        echo "✔ saved current state as a commit"
    fi
}

try_dms() {
    pacman -Q dux-shell >/dev/null 2>&1 || {
        echo "❌ dux-shell is not installed. Run first:"
        echo "   sudo pacman -S dux-shell"
        exit 1
    }
    state_commit
    git checkout -q try-dux-shell || { echo "❌ could not switch branch"; exit 1; }

    # stop the legacy stack
    pkill -x waybar; pkill -x swaync; pkill -x wob; pkill -x clipse; sleep 0.5

    hyprctl reload >/dev/null 2>&1
    pkill -x hypridle; sleep 0.3; setsid -f hypridle >/dev/null 2>&1
    setsid -f dms run >/dev/null 2>&1
    sleep 2
    pgrep -f "qs -p /run/user/.*/dms-shell" >/dev/null && \
        echo "✅ DMS is now running (your bar/notifications/launcher are DMS)." || \
        echo "⚠️  DMS did not start — check: dms run   (run it in a terminal to see errors)"
    echo "   NOTE: SUPER+L now locks with the DMS lock screen."
    echo "   To go back any time:  ~/dotfiles/scripts/dms.sh back"
}

back_to_main() {
    state_commit
    git checkout -q main || { echo "❌ could not switch branch"; exit 1; }

    # stop DMS
    pkill -x qs 2>/dev/null
    pkill -f "dms [r]un" 2>/dev/null
    sleep 0.5

    # restart the legacy stack
    hyprctl reload >/dev/null 2>&1
    pkill -x hypridle; sleep 0.3; setsid -f hypridle >/dev/null 2>&1
    setsid -f waybar  >/dev/null 2>&1
    setsid -f swaync  >/dev/null 2>&1
    setsid -f clipse -listen >/dev/null 2>&1
    rm -f "$XDG_RUNTIME_DIR/wob.sock"; mkfifo "$XDG_RUNTIME_DIR/wob.sock" 2>/dev/null
    setsid -f bash -c 'tail -f "$XDG_RUNTIME_DIR/wob.sock" | wob' >/dev/null 2>&1
    setsid -f waypaper --restore >/dev/null 2>&1
    sleep 1.5
    ok=1
    for p in waybar swaync hypridle wob; do
        pgrep -x "$p" >/dev/null || { echo "⚠️  $p did not start"; ok=0; }
    done
    [ "$ok" = 1 ] && echo "✅ Back on the main setup — waybar/swaync/hyprlock are live again."
}

case "${1:-}" in
    try)  try_dms ;;
    back) back_to_main ;;
    *) echo "Usage: ~/dotfiles/scripts/dms.sh try|back" ;;
esac
