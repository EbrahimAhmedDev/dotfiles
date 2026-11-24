#!/usr/bin/env bash
# Build a width-adjusted swayosd-server and install it to /usr/local/bin.
# The official `swayosd` package stays untouched; /usr/local/bin takes priority.
# Usage: build-swayosd.sh [width]   (default: 210)
# Revert with: sudo rm /usr/local/bin/swayosd-server
set -euo pipefail

WIDTH="${1:-210}"
VER="v0.3.2"
SRC="${XDG_CACHE_HOME:-$HOME/.cache}/swayosd-src"

command -v cargo >/dev/null || { echo "cargo is required" >&2; exit 1; }

if [ ! -d "$SRC/.git" ]; then
    git clone --depth 1 --branch "$VER" https://github.com/ErikReider/SwayOSD.git "$SRC"
fi

sed -i -E "s/set_width_request\([0-9]+\)/set_width_request(${WIDTH})/" \
    "$SRC/src/server/osd_window.rs"
grep -n 'set_width_request' "$SRC/src/server/osd_window.rs"

cargo build --release --bin swayosd-server \
    --manifest-path "$SRC/Cargo.toml" \
    --config 'profile.release.lto=false'

pkexec install -Dm755 "$SRC/target/release/swayosd-server" /usr/local/bin/swayosd-server

pkill -x swayosd-server 2>/dev/null || true
sleep 1
setsid swayosd-server >/dev/null 2>&1 < /dev/null &
echo "installed swayosd-server with width=${WIDTH}px and restarted it"
