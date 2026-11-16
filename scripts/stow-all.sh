#!/usr/bin/env bash
# Moves configs from ~/.config into ~/dotfiles/stow and links them. Safe to re-run.
set -eu
cfg="$HOME/.config"
stow="$HOME/dotfiles/stow"
mkdir -p "$stow"

dirs=(hypr waybar rofi swaync wlogout wob clipse nwg-displays nwg-look mako
      xsettingsd ghostty btop htop mpv micro waypaper gtk-3.0 gtk-4.0
      qt6ct fontconfig nmrs)
homefiles=(.zshrc .zprofile .zshenv)

link() { stow -d "$stow" -t "$HOME" "$1"; }

# folders in ~/.config
for d in "${dirs[@]}"; do
    [ -d "$cfg/$d" ] && [ ! -L "$cfg/$d" ] || continue
    mkdir -p "$stow/$d/.config"
    mv "$cfg/$d" "$stow/$d/.config/$d"
    link "$d"
    echo "linked: $d"
done

# zsh folder in ~/.config
if [ -d "$cfg/zsh" ] && [ ! -L "$cfg/zsh" ]; then
    mkdir -p "$stow/zsh/.config"
    mv "$cfg/zsh" "$stow/zsh/.config/zsh"
fi

# starship
if [ -f "$cfg/starship.toml" ] && [ ! -L "$cfg/starship.toml" ]; then
    mkdir -p "$stow/starship/.config"
    mv "$cfg/starship.toml" "$stow/starship/.config/starship.toml"
    link starship
fi

# files in $HOME go to the zsh package
for f in "${homefiles[@]}"; do
    [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ] || continue
    mkdir -p "$stow/zsh"
    mv "$HOME/$f" "$stow/zsh/$f"
done
[ -d "$stow/zsh" ] && link zsh

echo "done"
