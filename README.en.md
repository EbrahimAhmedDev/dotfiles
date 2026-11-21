# ebrahim's dotfiles

Linux (Arch) dotfiles for a Hyprland setup, managed with [GNU stow](https://www.gnu.org/software/stow/) and backed up on GitHub.

Everything is designed around one idea: **your real config files live in this repo, and your home folder is just links pointing at them.** Edit once, back up with one command, restore on any machine with one script.

🌍 **Language:** [العربية](README.md) • [English](README.en.md)

---

## TL;DR — the 3 commands you actually need

| Situation | Command |
|---|---|
| Installed a new program / added new configs | `dotsync` |
| Edited a file that already exists in the repo | `dotgit` |
| Changed something **outside your home** (e.g. SDDM theme) | `sync.sh` then `dotgit` |
| Fresh new machine | `git clone` + `./scripts/install.sh` (see [New machine setup](#new-machine-setup)) |

```sh
git clone https://github.com/EbrahimAhmedDev/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./scripts/install.sh
```

---

## How it works (the mental model)

### GNU stow in one paragraph

`stow` takes a folder of configs (a "package") and creates **symlinks** from your `$HOME` into it. Nothing is copied — your `~/.config/waybar` is literally a link into this repo.

```
~/.config/waybar/config                 ← symlink (a shortcut, not a real file)
        │
        └──→  ~/dotfiles/stow/waybar/.config/waybar/config        ← the real file
```

### What this buys you

- **Edit from anywhere.** Opening `~/.config/waybar/config` and editing it *is* editing the repo file. There is no "sync step" and no copy to forget.
- **One backup location.** The repo contains every config; `git push` backs up all of it.
- **Atomic removal.** Un-stowing a package removes all its links at once, leaving no crumbs.

### Files that can't be linked (the `copied/` exception)

Some programs refuse to follow symlinks, or rewrite the file in place and destroy the link (KDE apps like `kdeglobals`/`dolphinrc`, `mimeapps.list`). Those live in `copied/` and are **copied** into `~/.config` by `install.sh` instead of linked. `sync.sh` refreshes them from your live system.

### Files outside your home (the `system/` exception)

SDDM (the login screen) reads its config from `/etc/` and its theme from `/usr/share/` — outside your home, so stow can't reach those. `system/sddm/` holds copies of them, and `install.sh` puts them back with `sudo`.

---

## Repo layout

```
dotfiles/
├── stow/            # the actual configs, one folder = one stow package
│   ├── hypr/        #   .config/hypr/...    → linked to ~/.config/hypr
│   ├── waybar/      #   .config/waybar/...  → linked to ~/.config/waybar
│   ├── zsh/         #   special: holds $HOME-level files (.zshrc, .zprofile...)
│   └── ...
├── packages/        # package lists, generated automatically
│   ├── official.txt #   every pacman repo package (one name per line)
│   └── aur.txt      #   every AUR package
├── copied/          # configs that must be COPIED, not linked
├── system/          # system-level files (SDDM config + theme)
├── scripts/         # all the automation, see below
└── README.md
```

A "stow package" is just a folder whose internal structure mirrors `$HOME`. `stow/<pkg>/.config/foo` becomes `~/.config/foo` when stowed.

---

## The scripts

| Script | Runs when | What it does |
|---|---|---|
| `install.sh` | **once, on a new machine** | Installs packages from the lists, deletes conflicting default configs, stows everything, copies `copied/`, applies SDDM, enables SDDM |
| `dotsync.sh` | **daily / after installing anything** | Refreshes package lists, asks `y/N` for every new item in `~/.config`, links missing packages, moves loose zsh files, commits + pushes |
| `sync.sh` | **occasionally** (before leaving a machine) | Like `dotsync` but also refreshes `copied/` and `system/sddm/` (needs sudo) |
| `stow-all.sh` | legacy | The old manual-move script (older stow list) |

Two zsh aliases make the daily flow painless:

```sh
alias dotgit='cd ~/dotfiles && git add -A && git commit -m "update $(date +%F)" && git push'
alias dotsync="$HOME/dotfiles/scripts/dotsync.sh"
```

---

## Day-to-day workflow

### Installed a new program

```sh
sudo pacman -S fastfetch     # 1. install normally
dotsync                      # 2. refresh lists + claim its config + push
```

`dotsync` will prompt for every new unmanaged folder in `~/.config`:

```
stow 'fastfetch'? [y/N]
```

- `y` → the folder moves into `stow/fastfetch/`, gets linked, the package is recorded, everything is committed and pushed.
- Enter / `N` → the folder stays as a plain folder in `~/.config`, untracked and not asked about again.

Two independent things get updated, and both matter:

1. **The package** → recorded in `packages/` (so a new machine can install it)
2. **Its config** → moved into `stow/` (so a new machine gets it configured)

### Edited an existing config

```sh
micro ~/.zshrc        # edit + save — this IS the repo file (symlink)
source ~/.zshrc       # optional: apply to the current terminal
dotgit                # backup: commit + push
```

Check that a change was actually saved with `git status --short` inside `~/dotfiles` — a `M` line means Git sees it; empty output means nothing was saved.

> **Key distinction:** `source ~/.zshrc` makes the change live **on this machine now**. `dotgit` puts it **on GitHub**. They are different things that happen to be run together.

---

## System-level changes (outside your home) — no surprises ⚠️

Any change you make to **system files outside your home** — like switching the SDDM theme or editing login-screen settings — **is invisible to the automatic scripts**:

- `dotsync` only covers `~/.config` and the package lists — **it never touches `system/`**
- So the repo stays stuck on the old version, and if you reformat, `install.sh` will restore you **with the old setup**

### The rule

| You changed | Command |
|---|---|
| Configs inside `~/.config` or installed a program | `dotsync` |
| System files outside home (SDDM, boot settings...) | `sync.sh` ← then `dotgit` |
| Edited an existing file as-is | `dotgit` only |

```sh
./scripts/sync.sh    # refreshes system/sddm/ and copied/ from the current machine (needs sudo)
dotgit               # pushes the change to GitHub
```

> Note that `sync.sh` **does not commit or push** — it only refreshes files. Pushing is always manual via `dotgit`.
>
> **Practical rule before any reformat:** run `./scripts/sync.sh` fully once and push with `dotgit` — then you're guaranteed the repo knows about every new change.

---

## New machine setup

```sh
# 1. tools first
sudo pacman -S git github-cli stow
gh auth login                      # or set up SSH keys

# 2. get the repo
git clone https://github.com/EbrahimAhmedDev/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. everything else
./scripts/install.sh               # packages + links + copied/ + SDDM

reboot
```

What `install.sh` does internally:

1. Installs `stow`, then everything from `packages/official.txt` (and `packages/aur.txt` via `yay` if present).
2. For each stow package, deletes conflicting default configs in `$HOME` first (stow refuses to link over real files), then stows it.
3. Copies `copied/*` into `~/.config` (with `cp -n`, won't overwrite).
4. Applies `system/sddm/*` to `/etc/` and `/usr/share/sddm/themes/silent`, enables SDDM.

---

## Advanced notes

### Un-stowing / re-stowing a single package

```sh
cd ~/dotfiles/stow
stow -D -t "$HOME" waybar    # remove all waybar links (files stay in the repo)
stow -R -t "$HOME" waybar    # re-create them (after adding files, for example)
```

`stow -D` never deletes repo files — only the links in `$HOME`. That makes it safe to experiment.

### Stow conflicts (the most common failure)

If you stow and get `CONFLICT: ... existing file ...`, it means a real (non-link) file is sitting where the link should go — usually a default config the program generated. Fix: inspect it, merge anything you want to keep, delete it, stow again. `install.sh` handles this automatically by deleting `.config/<pkg>` defaults before stowing.

### How the package lists work

- `pacman -Qqen` = names of all packages installed from the official repos.
- `pacman -Qqem` = names of all packages installed from AUR.
- `install.sh` feeds both straight back into pacman/yay, so a fresh machine converges to the same program set.
- These lists are **snapshots** — they only know what existed at the last `dotsync`/`sync`. Install something and forget to run it, and that program won't be restored.

### What is deliberately NOT tracked

- `stow/clipse/` clipboard history, logs and `tmp_files/` — clipboard history is a password leak in waiting.
- `*.bak`, `*~`, `*.swp` — editor noise.
- `stow/*/.config/**/stack.toml` — runtime state.

### Why `git`, and what it does NOT do

Git gives you history (every commit is a restore point) and the GitHub backup. It does **not** push automatically — commit and push are always explicit (`dotgit` / `dotsync`). Saving a file in your editor saves it to disk only.

### Restoring a single config without the full install

```sh
git clone https://github.com/EbrahimAhmedDev/dotfiles.git ~/dotfiles
cd ~/dotfiles/stow && stow -t "$HOME" waybar     # just one package
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `dotsync` asks about a folder every run | You answered `N`, but the folder still exists unmanaged | Expected. Answer `N` forever, or `y` if you actually want it |
| App changed its config but repo didn't update | App wrote to a `copied/`-style file, or you edited a file stow doesn't own | Check if the file is a symlink (`ls -la ~/.config/<name>`); if it's a real file, move it into the right package yourself or run `sync.sh` |
| `git status` empty but you "did edit" | The edit never got saved (terminal-typed changes don't edit files) | Edit with an actual editor and save |
| `CONFLICT` during stow | Real file where a link should be | See [Stow conflicts](#stow-conflicts-the-most-common-failure) |
| A program "resets" its settings | It overwrites its config; if it's linked, changes still land in the repo — commit after configuring | `dotgit` |

---

## What's included

Hyprland, Waybar, Rofi, SwayNC, wlogout, Mako, Ghostty, Wob, Clipse, Waypaper,
GTK 3/4, Qt6ct, Fontconfig, Micro, btop, htop, mpv, nwg-displays, nwg-look,
Starship, Zsh, and the SDDM login screen.
