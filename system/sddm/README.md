# SDDM

The login screen is SDDM, using the **Maldives** theme selected in
`sddm.conf.d/20-theme.conf`. Maldives is one of the stock themes shipped with
the `sddm` package (`elarun`, `maldives`, `maya`); no third-party themes are
kept in this repo or installed on the system.

- `sddm.conf` only clears `InputMethod`, which keeps SDDM's on-screen keyboard
  disabled while the physical keyboard keeps working.
- `sddm.conf.d/10-fix-logout.conf` disables session reuse so logging out
  returns to the greeter cleanly.
- `sddm.conf.d/20-theme.conf` selects the theme.

`../../scripts/install.sh` applies these files to `/etc/` and enables
`sddm.service`. `../../scripts/sync.sh` copies them back from the live system.

If SDDM is ever replaced by another display manager, disable that manager
before enabling `sddm.service` so only one greeter starts at boot.
