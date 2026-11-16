#!/usr/bin/env bash
# Run before moving to a new machine: refreshes package lists, copied files and SDDM.
set -eu
dot="$HOME/dotfiles"
cfg="$HOME/.config"
mkdir -p "$dot"/{packages,copied,system}

pacman -Qqen > "$dot/packages/official.txt"
pacman -Qqem > "$dot/packages/aur.txt"

for f in kdeglobals dolphinrc mimeapps.list user-dirs.dirs pavucontrol.ini; do
    [ -f "$cfg/$f" ] && cp -a "$cfg/$f" "$dot/copied/"
done

rm -rf "$dot/system/sddm"
mkdir -p "$dot/system/sddm"
[ -d /etc/sddm.conf.d ] && sudo cp -r /etc/sddm.conf.d "$dot/system/sddm/"
[ -f /etc/sddm.conf ] && sudo cp /etc/sddm.conf "$dot/system/sddm/"
[ -d /usr/share/sddm/themes/silent ] && sudo cp -r /usr/share/sddm/themes/silent "$dot/system/sddm/theme-silent"
sudo chown -R "$(id -un):$(id -gn)" "$dot/system"

echo "sync done"
du -sh "$dot"
