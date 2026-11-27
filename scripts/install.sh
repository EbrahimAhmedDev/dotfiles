#!/usr/bin/env bash
# Run on a NEW machine. It deletes default configs that would block the links.
set -eu
dot="$HOME/dotfiles"
stow="$dot/stow"

sudo pacman -S --needed --noconfirm stow
sudo pacman -S --needed --noconfirm - < "$dot/packages/official.txt"
if command -v yay >/dev/null; then
    yay -S --needed --noconfirm - < "$dot/packages/aur.txt"
else
    echo "yay missing: install it, then run: yay -S --needed - < $dot/packages/aur.txt"
fi

# remove defaults that conflict with the links, then link each package
for p in "$stow"/*/; do
    name=$(basename "$p")
    for item in "$p".config/*; do
        [ -e "$item" ] && rm -rf "$HOME/.config/$(basename "$item")"
    done
    for item in "$p".[!.]*; do
        [ -f "$item" ] && rm -f "$HOME/$(basename "$item")"
    done
    stow -d "$stow" -t "$HOME" "$name"
done

cp -n "$dot"/copied/* "$HOME/.config/" 2>/dev/null || true

# udev rule: let the user sync the audio mute LEDs (PipeWire doesn't do it)
[ -d "$dot/system/udev" ] && {
    sudo cp "$dot"/system/udev/*.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    sudo udevadm trigger
}

# SDDM
s="$dot/system/sddm"
sudo mkdir -p /etc/sddm.conf.d
[ -d "$s/sddm.conf.d" ] && sudo cp -r "$s/sddm.conf.d/." /etc/sddm.conf.d/
[ -f "$s/sddm.conf" ] && sudo cp "$s/sddm.conf" /etc/sddm.conf
sudo systemctl disable ly@tty2.service 2>/dev/null || true
sudo systemctl enable sddm

echo "done, reboot now"
