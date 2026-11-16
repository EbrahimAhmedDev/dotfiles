#!/usr/bin/env bash
# Run after installing anything new or tweaking configs.
# - refreshes package lists (official + AUR)
# - stows every NEW folder/file in ~/.config that you approve (default: no)
# - links stow packages that exist in the repo but not in ~/.config yet
# - moves loose zsh dotfiles from $HOME into the zsh package
# - commits and pushes everything
set -eu
dot="$HOME/dotfiles"
cfg="$HOME/.config"
stow="$dot/stow"
mkdir -p "$stow" "$dot/packages"

link() { stow -d "$stow" -t "$HOME" "$1"; }

echo "== package lists"
pacman -Qqen > "$dot/packages/official.txt"
pacman -Qqem > "$dot/packages/aur.txt"

echo "== new configs (unmanaged items in ~/.config)"
shopt -s nullglob
for item in "$cfg"/*; do
    name="$(basename "$item")"
    [ -L "$item" ] && continue                  # already managed by stow
    [ -e "$stow/$name" ] && continue            # a stow package already exists
    printf "stow '%s'? [y/N] " "$name"
    read -r ans
    [ "$ans" = "y" ] || continue
    if [ "$name" = "starship.toml" ]; then
        mkdir -p "$stow/starship/.config"
        mv "$item" "$stow/starship/.config/starship.toml"
        link starship
    else
        mkdir -p "$stow/$name/.config"
        mv "$item" "$stow/$name/.config/$name"
        link "$name"
    fi
    echo "linked: $name"
done

echo "== repo packages not linked yet"
for pkg in "$stow"/*/; do
    pkg="$(basename "$pkg")"
    [ "$pkg" = "zsh" ] && continue              # zsh is home-file based, handled below
    if [ ! -e "$cfg/$pkg" ]; then
        link "$pkg"
        echo "linked: $pkg"
    fi
done

echo "== zsh home files"
changed_zsh=0
for f in .zshrc .zprofile .zshenv; do
    if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        mkdir -p "$stow/zsh"
        mv "$HOME/$f" "$stow/zsh/$f"
        changed_zsh=1
    fi
done
[ "$changed_zsh" = 1 ] && link zsh

echo "== git"
cd "$dot"
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "dotsync $(date +%F %R)"
fi
git push

echo "done ✓"
