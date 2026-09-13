# Grimoire OS

*A long journey, taken slowly.*

---

Grimoire OS is a personal take on what a desktop should feel like: quiet,
unhurried, and built around focus instead of noise. It's an Arch-based
setup — Hyprland, the Caelestia shell, a small and deliberate set of
apps — wrapped in a calm, muted aesthetic inspired by old magic and long
journeys.

This isn't a fork of an existing distro and it isn't trying to compete
with the big projects out there. It's closer to a well-kept dotfiles repo
that happens to set up the whole system for you. No ISO, no installer
wizard with fifty screens — just Arch, and then Grimoire.

## Philosophy

- **One tool per job.** No app is installed "just in case." Helium for
  browsing, kitty for the terminal, Boostnote for writing things down —
  and that's the list (some are optional, picked during setup).
- **No motion for motion's sake.** Animations exist where they help you
  understand what just happened, not to look impressive in a screenshot.
- **The system should get out of your way.** Set it up once, forget it's
  there.

## What's included

**Desktop**
- Hyprland (Wayland compositor)
- Caelestia shell (Quickshell-based)
- SDDM login manager
- [HyprMod](https://github.com/BlueManCZ/hyprmod) — a graphical settings
  app for Hyprland, so you can actually use your desktop instead of
  endlessly tuning its config file

**Apps**
- Helium — browser (Chromium-based, privacy-focused)
- kitty — terminal, pre-configured with a muted color palette and
  [UDEV Gothic](https://github.com/yuru7/udev-gothic) (Latin text stays
  fully readable; Kanji and symbols get a distinct look)
- VSCodium, HyprMod always included; Discord / Spotify / Boostnote
  selectable during setup

**Terminal**
- fish as the default shell
- fastfetch, pre-configured with its own vocabulary instead of generic
  labels — your uptime becomes "Time Since Waking," swap becomes "Mana,"
  memory becomes "Mind." A system readout that reads like a character
  sheet instead of a spec list.

### About the aesthetic

The color palette, the renamed fastfetch fields, the overall mood —
all inspired by a love for slow, thoughtful fantasy stories about long
lives and quiet magic. None of it reproduces any specific show's
artwork, dialogue, or official assets — it's an original palette and
original wording built in that spirit, not a copy of anything.

If you want to add your own themed wallpaper, keep it local to your own
machine rather than committing it to a public fork of this repo —
redistributing someone else's copyrighted art (official or fan-made)
through a public GitHub repo is a different thing than just using it
for yourself.

## Installation

You'll need a fresh, minimal Arch install first (`archinstall` is fine —
just skip picking a desktop environment, Grimoire handles that part).

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zenez999/grimoire-os/main/grimoire-boot.sh)"
```

That one line clones this repo and runs the setup. Twenty minutes to an
hour depending on your connection, then a reboot.

Prefer to see what you're running first:

```bash
git clone https://github.com/zenez999/grimoire-os.git
cd grimoire-os
chmod +x install.sh
./install.sh
```

### Bring your own wallpaper

Drop images into a `wallpapers/` folder at the root of your own **local**
copy (not necessarily committed to a public fork — see the note above).
Name your favorite `default.jpg` (or `.png`) and it'll be set active
automatically on first boot.

## After it's running

- Change wallpaper: `caelestia wallpaper -f <path>`
- Hyprland tweaks: `~/.config/caelestia/hypr-vars.lua`
- Shell config: `~/.config/caelestia/shell.json`
- kitty font/colors: `~/.config/kitty/kitty.conf`
- fastfetch wording: `~/.config/fastfetch/config.jsonc`

## Requirements

- A fresh, minimal Arch install
- An internet connection
- A normal user with `sudo` (not root)
- Nothing exotic hardware-wise — runs comfortably on an 8th-gen i5 with
  8GB of RAM

## License

MIT. Do what you want with it — fork it, strip it down, make it yours.

---

*A long journey is just a lot of short, quiet days.*
