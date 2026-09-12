# ⛩ Zazen Linux

*座禅 — sitting meditation. The practice of returning to stillness.*

---

Zazen Linux is a personal take on what a desktop should feel like: quiet,
uncluttered, and built around focus instead of noise. It's an Arch-based
setup — Hyprland, the Caelestia shell, a small and deliberate set of apps —
wrapped in a calm Japanese aesthetic from the very first boot.

I built this because I was tired of spending more time configuring my
desktop than actually using it. Every rice I made kept drifting — a widget
here, a theme there — until it stopped feeling like *mine*. Zazen is the
version I finally stopped tinkering with. One command, and it's done.

This isn't a fork of an existing distro and it isn't trying to compete
with the big projects out there. It's closer to a well-kept dotfiles repo
that happens to set up the whole system for you. No ISO, no installer
wizard with fifty screens — just Arch, and then Zazen.

---

## What it looks like

A dark, minimal desktop with a torii-gate spirit running through it —
SDDM greets you with a Japanese-aesthetic login screen, Hyprland handles
the window management, and the Caelestia shell ties the whole thing
together with a clean, quiet bar and launcher.

*(Screenshots coming once I stop changing the wallpaper every week.)*

## Philosophy

A few small rules guided every choice in this project:

- **One tool per job.** No app is installed "just in case." Floorp for
  browsing, kitty for the terminal, Boostnote for writing things down —
  and that's the list.
- **No motion for motion's sake.** Animations exist where they help you
  understand what just happened, not to look impressive in a screen
  recording.
- **The system should get out of your way.** Ideally you set it up once
  and then forget it's there.

## What's included

**Desktop**
- Hyprland (Wayland compositor)
- Caelestia shell (Quickshell-based)
- SDDM with the Japanese-aesthetic theme
- [HyprMod](https://github.com/BlueManCZ/hyprmod) — a graphical settings app
  for Hyprland, so you can actually use your desktop instead of endlessly
  tuning its config file

**Apps**
- zen — browser
- kitty — terminal
- Discord, VSCodium, Boostnote, Spotify

**Terminal**
- fish as the default shell
- btop, fastfetch

### About HyprMod

Hyprland is famously powerful and famously text-config-driven — every
change means opening `hyprland.conf`, editing it by hand, and hoping you
didn't break your bindings. HyprMod turns that into a normal settings app:
live preview as you adjust things, undo with Ctrl+Z, and your hand-written
config stays untouched (it writes to its own file, then loads it
alongside yours). It doesn't touch anything outside Hyprland itself — no
Wi-Fi, no theming, no scope creep. Just a settings window for the thing
that used to need a text editor.

Open it from the app launcher, or run `hyprmod` in a terminal.

## Installation

You'll need a fresh, minimal Arch install first (`archinstall` is fine —
just skip picking a desktop environment, Zazen handles that part).

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zenez999/zazen-linux/main/zazen-boot.sh)"
```

That one line clones this repo and runs the setup. It installs everything
above, removes the defaults it doesn't need (no Firefox, no foot — Floorp
and kitty take their place), and sets up the theme. Twenty minutes to an
hour depending on your connection, then a reboot.

Prefer to see what you're running first:

```bash
git clone https://github.com/zenez999/zazen-linux.git
cd zazen-linux
chmod +x install.sh
./install.sh
```

### Bring your own wallpaper

Drop images into a `wallpapers/` folder at the root of your own fork. Name
your favorite `default.jpg` (or `.png`) and it'll be set active
automatically on first boot. Everything else just joins the rotation.

## After it's running

- Change wallpaper: `caelestia wallpaper -f <path>`
- Hyprland tweaks: `~/.config/caelestia/hypr-vars.lua`
- Shell config: `~/.config/caelestia/shell.json`
- Different SDDM theme variant: edit `ConfigFile=` in
  `/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop`

## Requirements

- A fresh, minimal Arch install
- An internet connection
- A normal user with `sudo` (not root)
- Nothing exotic hardware-wise — runs comfortably on an 8th-gen i5 with
  8GB of RAM

## License

MIT. Do what you want with it — fork it, strip it down, make it yours.
That's kind of the point.

---

*一期一会 — this moment, once. Thanks for stopping by.*
