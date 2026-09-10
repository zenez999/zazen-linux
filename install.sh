#!/usr/bin/env bash
#
#   ⛩  Z A Z E N   L I N U X  ⛩
#   An Arch-based system built around stillness and focus.
#   https://github.com/zenez999/Japan_arch.install
#
#   MIT Licensed — free and open source.
#   NICHT als root ausführen. sudo wird intern genutzt.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Farben & Darstellung
# ---------------------------------------------------------------------------

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

ZEN_QUOTES=(
    "座れば座るほど、心は静まる。 — The more you sit, the calmer the mind."
    "初心 — Approach each step with a beginner's mind."
    "山があるから、登る。 — Because the mountain is there, we climb."
    "呼吸を数えよ、急がず。 — Count your breaths, without hurry."
    "一期一会 — Treasure this moment; it will not come again."
    "無 — Empty the mind, and let the system build itself."
)

banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
                                 ⛩
        ╔══════════════════════════════════════════╗
        ║                                          ║
        ║        Z A Z E N   L I N U X             ║
        ║        座禅 — the art of sitting          ║
        ║                                          ║
        ╚══════════════════════════════════════════╝
EOF
    echo -e "${RESET}${DIM}              built on Arch · open source · MIT${RESET}\n"
}

zen_pause() {
    local quote="${ZEN_QUOTES[$RANDOM % ${#ZEN_QUOTES[@]}]}"
    echo -e "${DIM}   ${quote}${RESET}"
    sleep 1
}

step()  { echo -e "\n${BOLD}${CYAN}==> $1${RESET}"; zen_pause; }
info()  { echo -e "${DIM}    $1${RESET}"; }
warn()  { echo -e "${YELLOW}!!  $1${RESET}"; }
ok()    { echo -e "${GREEN}✓   $1${RESET}"; }
die()   { echo -e "${RED}✗ FEHLER: $1${RESET}"; exit 1; }

banner
sleep 1

# ---------------------------------------------------------------------------
# Vorprüfungen
# ---------------------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    die "Bitte NICHT als root ausführen. Als normaler User starten (sudo wird intern genutzt)."
fi

command -v sudo >/dev/null 2>&1 || die "sudo ist nicht installiert."

step "Verbindung wird geprüft"
ping -c1 -W2 archlinux.org >/dev/null 2>&1 || die "Keine Internetverbindung. Erst WLAN/LAN einrichten (nmtui / iwctl), dann erneut starten."
ok "Verbindung steht"

# ---------------------------------------------------------------------------
# 1. System aktualisieren
# ---------------------------------------------------------------------------
step "System wird aktualisiert"
sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------------
# 2. Basis-Pakete + AUR-Helper (paru)
#    Bewusst OHNE firefox/foot — Zazen nutzt Floorp + kitty
# ---------------------------------------------------------------------------
step "Grundlagen werden gelegt (Basis-Pakete)"
sudo pacman -S --needed --noconfirm \
    base-devel git curl wget unzip \
    networkmanager \
    hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    qt6-base qt6-declarative qt6-svg qt6-imageformats qt6-multimedia-ffmpeg qt6-virtualkeyboard qt6-shadertools qt6-5compat \
    fish kitty btop fastfetch \
    sddm \
    pipewire pipewire-pulse pipewire-alsa wireplumber \
    brightnessctl playerctl \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji \
    thunar \
    cmake ninja

sudo systemctl enable NetworkManager

if ! command -v paru >/dev/null 2>&1; then
    step "AUR-Helfer 'paru' wird gebaut"
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
    (cd "$tmpdir/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
else
    info "paru bereits vorhanden, überspringe"
fi

# ---------------------------------------------------------------------------
# 3. AUR-Pakete: Caelestia + Zazen-App-Auswahl
# ---------------------------------------------------------------------------
step "Die Werkzeuge werden versammelt (AUR-Pakete)"
paru -S --needed --noconfirm \
    caelestia-cli \
    quickshell-git \
    ddcutil \
    libcava \
    aubio \
    libqalculate \
    power-profiles-daemon \
    ttf-material-symbols-variable \
    ttf-rubik-vf \
    qt6-m3shapes-git \
    swappy \
    floorp-bin \
    discord \
    vscodium-bin \
    boostnote-bin \
    spotify

sudo systemctl enable power-profiles-daemon

# ---------------------------------------------------------------------------
# 4. Caelestia Shell + Dotfiles
# ---------------------------------------------------------------------------
step "Die Shell erwacht (Caelestia wird eingerichtet)"
caelestia install || warn "caelestia install meldete einen Fehler — ggf. manuell mit 'caelestia install' erneut ausführen"

step "Unnötiges wird losgelassen (firefox/foot entfernen, falls mitinstalliert)"
pacman -Qi firefox >/dev/null 2>&1 && sudo pacman -Rns --noconfirm firefox || true
pacman -Qi foot    >/dev/null 2>&1 && sudo pacman -Rns --noconfirm foot    || true

# ---------------------------------------------------------------------------
# 5. Floorp + kitty als Standard setzen
# ---------------------------------------------------------------------------
step "Floorp und kitty werden zu deinen Standard-Werkzeugen"

CAELESTIA_CFG="$HOME/.config/caelestia"
mkdir -p "$CAELESTIA_CFG"

HYPR_VARS="$CAELESTIA_CFG/hypr-vars.lua"
if [[ -f "$HYPR_VARS" ]]; then
    warn "$HYPR_VARS existiert bereits — bitte manuell prüfen: browser=\"floorp\", terminal=\"kitty\""
else
    cat > "$HYPR_VARS" << 'EOF'
return {
    browser  = "floorp",
    terminal = "kitty",
}
EOF
    ok "hypr-vars.lua erstellt (browser=floorp, terminal=kitty)"
fi

SHELL_JSON="$CAELESTIA_CFG/shell.json"
if [[ -f "$SHELL_JSON" ]]; then
    warn "$SHELL_JSON existiert bereits — bitte 'general.apps.terminal' manuell auf [\"kitty\"] setzen"
else
    cat > "$SHELL_JSON" << 'EOF'
{
    "general": {
        "apps": {
            "terminal": ["kitty"],
            "explorer": ["thunar"]
        }
    }
}
EOF
    ok "shell.json erstellt (terminal=kitty)"
fi

# ---------------------------------------------------------------------------
# 6. Fish als Standard-Shell
# ---------------------------------------------------------------------------
step "Fish wird dein Zuhause im Terminal"
FISH_PATH=$(command -v fish)
grep -q "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
sudo chsh -s "$FISH_PATH" "$USER"

# ---------------------------------------------------------------------------
# 7. SDDM: Japanese-Aesthetic-Theme
# ---------------------------------------------------------------------------
step "Der Eingang wird gestaltet (SDDM Japanese-Aesthetic-Theme)"

if [[ ! -d /usr/share/sddm/themes/sddm-astronaut-theme ]]; then
    sudo git clone -b master --depth 1 \
        https://github.com/keyitdev/sddm-astronaut-theme.git \
        /usr/share/sddm/themes/sddm-astronaut-theme
fi

sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/ 2>/dev/null || true

echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf >/dev/null

sudo mkdir -p /etc/sddm.conf.d
echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

THEME_META="/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop"
if [[ -f "$THEME_META" ]]; then
    sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/japanese_aesthetic.conf|' "$THEME_META"
else
    warn "metadata.desktop nicht gefunden — Theme-Variante manuell auf 'Themes/japanese_aesthetic.conf' setzen"
fi

sudo systemctl enable sddm

# ---------------------------------------------------------------------------
# 8. Eigenes Wallpaper übernehmen
# ---------------------------------------------------------------------------
step "Ein Blick nach draußen (Wallpaper wird eingerichtet)"

WALLPAPER_SRC="$SCRIPT_DIR/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/Wallpapers"

if [[ -d "$WALLPAPER_SRC" ]] && [[ -n "$(ls -A "$WALLPAPER_SRC" 2>/dev/null)" ]]; then
    mkdir -p "$WALLPAPER_DEST"
    cp -r "$WALLPAPER_SRC"/. "$WALLPAPER_DEST"/
    ok "Wallpaper nach $WALLPAPER_DEST kopiert"

    DEFAULT_WALLPAPER=$(find "$WALLPAPER_DEST" -maxdepth 1 -iname "default.*" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n1)
    [[ -z "$DEFAULT_WALLPAPER" ]] && DEFAULT_WALLPAPER=$(find "$WALLPAPER_DEST" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort | head -n1)

    if [[ -n "$DEFAULT_WALLPAPER" ]]; then
        caelestia wallpaper -f "$DEFAULT_WALLPAPER" 2>/dev/null || info "Wallpaper wird beim ersten Login automatisch aktiv"
    fi
else
    info "Kein 'wallpapers/'-Ordner gefunden — Standard-Wallpaper bleibt aktiv"
fi

# ---------------------------------------------------------------------------
# Fertig
# ---------------------------------------------------------------------------
echo -e "\n${CYAN}"
cat << 'EOF'
                                 ⛩
        ╔══════════════════════════════════════════╗
        ║   Die Installation ist vollendet.        ║
        ║   完成 — kansei                           ║
        ╚══════════════════════════════════════════╝
EOF
echo -e "${RESET}"
info "Neustart: sudo reboot"
info "Standard-Browser: Floorp  |  Standard-Terminal: kitty"
info "Theme testen ohne Neustart:"
info "  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/"
echo -e "\n${DIM}   静寂の中に力あり — There is strength within stillness.${RESET}\n"
