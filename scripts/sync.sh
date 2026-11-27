#!/usr/bin/env bash
# Run before moving to a new machine: refreshes package lists, copied files and SDDM.
set -eu
dot="$HOME/dotfiles"
cfg="$HOME/.config"
mkdir -p "$dot"/{packages,copied,system}

pacman -Qqen > "$dot/packages/official.txt"
pacman -Qqem > "$dot/packages/aur.txt"

for f in kdeglobals dolphinrc mimeapps.list; do
    [ -f "$cfg/$f" ] && cp -a "$cfg/$f" "$dot/copied/"
done

mkdir -p "$dot/system/sddm/sddm.conf.d"
[ -d /etc/sddm.conf.d ] && sudo cp -r /etc/sddm.conf.d/. "$dot/system/sddm/sddm.conf.d/"
[ -f /etc/sddm.conf ] && sudo cp /etc/sddm.conf "$dot/system/sddm/sddm.conf"
sudo chown -R "$(id -un):$(id -gn)" "$dot/system"

echo "sync done"
du -sh "$dot"
