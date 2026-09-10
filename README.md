# ⛩ Zazen Linux

> 座禅 — the art of sitting. An Arch-based system built around stillness and focus.

Ein Ein-Befehl-Installer (Omarchy-Style), der auf einer frischen Arch-Installation
Hyprland + die Caelestia Shell + eine feste, ruhige App-Auswahl einrichtet.
Kein eigenes ISO nötig — du installierst normales Arch, Zazen erledigt den Rest.

Frei und quelloffen unter der [MIT-Lizenz](./LICENSE).

## Installation

Nach einer frischen, minimalen Arch-Installation (z. B. via `archinstall`,
ohne Desktop-Umgebung ausgewählt):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zenez999/Japan_arch.install/main/zazen-boot.sh)"
```

Das Bootstrap-Skript klont das komplette Repository (inklusive deiner
`wallpapers/`) und startet danach automatisch `install.sh`.

Alternativ per `git clone`:

```bash
git clone https://github.com/zenez999/Japan_arch.install.git
cd Japan_arch.install
chmod +x install.sh
./install.sh
```

## Was Zazen Linux mitbringt

**Desktop**
- Hyprland (Wayland) + Caelestia Shell (Quickshell)
- SDDM mit dem Japanese-Aesthetic-Theme

**Apps (statt Firefox/Foot)**
- Floorp (Standard-Browser)
- kitty (Standard-Terminal)
- Discord, VSCodium, Boostnote, Spotify

**Terminal**
- fish als Standard-Shell
- btop, fastfetch

## Eigenes Wallpaper mitbringen

Leg einen Ordner `wallpapers/` im Repo-Root an. Eine Datei namens
`default.jpg` (oder `.png`/`.jpeg`) wird beim Setup automatisch als
aktives Wallpaper gesetzt; weitere Bilder landen mit im Wallpaper-Wechsler.

```
Japan_arch.install/
├── zazen-boot.sh
├── install.sh
├── wallpapers/
│   └── default.jpg
└── README.md
```

## Voraussetzungen

- Frische, minimale Arch-Installation
- Internetverbindung
- Normaler Benutzer mit `sudo`-Rechten (nicht root)
- Läuft flüssig auf Intel i5 (8. Gen) + 8 GB RAM

## Nach der Installation

- Wallpaper wechseln: `caelestia wallpaper -f <pfad>`
- Hyprland-Standardwerte anpassen: `~/.config/caelestia/hypr-vars.lua`
- Shell-Konfiguration: `~/.config/caelestia/shell.json`
- SDDM-Theme-Variante ändern:
  `/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop`
  → Zeile `ConfigFile=Themes/<name>.conf`

## Mitwirken

Zazen Linux ist offen für Beiträge — Issues und Pull Requests sind willkommen.

一期一会 — treasure this moment.
