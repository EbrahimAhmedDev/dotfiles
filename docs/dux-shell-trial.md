# Trial: Dux Shell (formerly Dank Material Shell / DMS)

Goal: try a full quickshell-based desktop shell on top of Hyprland, alongside
the existing custom setup (waybar + swaync + rofi), without breaking anything.

## What it is
Dux Shell (package `dux-shell` in extra — formerly `dms-shell` / DMS 2.0) is a
complete Material 3 desktop shell: status bar, notification center, lock
screen, launcher, settings, media control — running on Quickshell.

## Install (sudo, one command)
```bash
sudo pacman -S dux-shell
```
Dependencies auto-installed: `quickshell` (Qt6 toolkit) + `accountsservice`.

## Run manually (trial — nothing touches autostart)
```bash
dms run        # the binary keeps the `dms` name
```
Run it inside the session to try it live. Kill it any time with
`pkill -f dms` (or Ctrl+C in its terminal).

## What to watch for
- Notification overlap: swaync is running; if DMS shows duplicate
  notifications, kill swaync during the trial (`pkill -x swaync`).
- Bar overlap: waybar stays; move/deselect the DMS bar or kill waybar
  temporarily to compare.
- Quickshell runs its own greeter/lock if configured — do NOT enable DMS lock
  while testing unless ready to debug; the current hyprlock setup stays.

## Rollback
Everything here is a manual process — no dotfiles paths are changed by the
install. If unhappy:
```bash
sudo pacman -Rns dux-shell quickshell accountsservice
```
(accountsservice only if nothing else needs it; harmless to keep.)

## If we adopt it
- add `exec-once = dms run` behind a feature flag / session choice
- replace keybinds for launcher/notifications with dms's ipc
- keep waybar/swaync files in the repo (unused when dms active)
