# SDDM setup

The selected login theme is `nier-automata`, configured in
`sddm.conf.d/20-nier.conf`. The old `silent` theme remains installed as a
fallback. `/etc/sddm.conf` disables SDDM's Qt virtual keyboard while keeping
the physical keyboard available; it no longer overrides the selected theme or
points at Silent's QML components.

`theme-nier-automata/` is the qylock NieR:Automata theme (upstream GPL-3.0;
see its `LICENSE` and `NOTICE.md`). It bundles **Zen Kaku Gothic New Medium**
as the closest practical open-license substitute we found for the theme's
original FOT-Rodin Pro DB. Its SIL Open Font License is in
`theme-nier-automata/font/OFL.txt`. The original Rodin font is proprietary and
is not redistributed; see `theme-nier-automata/font/README.txt` if you have a
licensed copy.

`../../scripts/install.sh` installs both Silent and NieR themes, and applies
the SDDM configuration. `../../scripts/sync.sh` refreshes these files from the
live system.

## Switch back to Silent

To select Silent for the next greeter start, replace the NieR drop-in with:

```sh
sudo tee /etc/sddm.conf.d/20-nier.conf >/dev/null <<'EOF'
[General]
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF
```

The existing `/etc/sddm.conf` keeps `InputMethod=qtvirtualkeyboard`. No SDDM
restart is needed during the current desktop session; the settings are read
when the login greeter starts.
