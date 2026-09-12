#!/usr/bin/env bash
#
#   ⛩  Z A Z E N   L I N U X  ⛩
#   An Arch-based system built around stillness and focus.
#   https://github.com/zenez999/zazen-linux
#
#   MIT Licensed — free and open source.
#   NICHT als root ausführen. sudo wird intern genutzt.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Umgebung erkennen: rohe Linux-Konsole (vor Hyprland) kann kein Kanji
# darstellen (Font-Limit des Framebuffer-Konsolentreibers, nicht behebbar
# ohne kmscon/fbterm). Wir zeigen dort nur die englische Übersetzung.
# ---------------------------------------------------------------------------
IS_RAW_TTY=false
[[ "${TERM:-}" == "linux" ]] && IS_RAW_TTY=true

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

# Jedes Zitat als "Kanji|Englisch" — im rohen TTY wird nur der Teil nach
# dem | gezeigt, sonst beides.
ZEN_QUOTES=(
    "座れば座るほど、心は静まる。|The more you sit, the calmer the mind."
    "初心|Approach each step with a beginner's mind."
    "山があるから、登る。|Because the mountain is there, we climb."
    "呼吸を数えよ、急がず。|Count your breaths, without hurry."
    "一期一会|Treasure this moment; it will not come again."
    "無|Empty the mind, and let the system build itself."
)

zen_line() {
    # Gibt ein zufälliges Zitat zurück, TTY-sicher
    local entry="${ZEN_QUOTES[$RANDOM % ${#ZEN_QUOTES[@]}]}"
    local kanji="${entry%%|*}"
    local english="${entry##*|}"
    if [[ "$IS_RAW_TTY" == true ]]; then
        echo "$english"
    else
        echo "${kanji} — ${english}"
    fi
}

HAVE_GUM=false
command -v gum >/dev/null 2>&1 && HAVE_GUM=true

START_TIME=$(date +%s)
TOTAL_STEPS=9
CURRENT_STEP=0

banner() {
    if [[ "$HAVE_GUM" == true ]]; then
        if [[ "$IS_RAW_TTY" == true ]]; then
            gum style --border double --align center --width 46 --padding "1 2" \
                --border-foreground 51 --foreground 51 --bold \
                "ZAZEN LINUX" "" "the art of sitting"
        else
            gum style --border double --align center --width 46 --padding "1 2" \
                --border-foreground 51 --foreground 51 --bold \
                "⛩  ZAZEN LINUX  ⛩" "" "座禅 — the art of sitting"
        fi
        gum style --align center --width 46 --faint "built on Arch · open source · MIT"
    else
        echo -e "${CYAN}"
        if [[ "$IS_RAW_TTY" == true ]]; then
            cat << 'EOF'
        ╔══════════════════════════════════════════╗
        ║                                          ║
        ║        Z A Z E N   L I N U X             ║
        ║        the art of sitting                ║
        ║                                          ║
        ╚══════════════════════════════════════════╝
EOF
        else
            cat << 'EOF'
                                 ⛩
        ╔══════════════════════════════════════════╗
        ║                                          ║
        ║        Z A Z E N   L I N U X             ║
        ║        座禅 — the art of sitting          ║
        ║                                          ║
        ╚══════════════════════════════════════════╝
EOF
        fi
        echo -e "${RESET}${DIM}              built on Arch · open source · MIT${RESET}\n"
    fi
    echo ""
}

zen_pause() {
    local quote
    quote="$(zen_line)"
    if [[ "$HAVE_GUM" == true ]]; then
        gum style --faint --italic "   ${quote}"
    else
        echo -e "${DIM}   ${quote}${RESET}"
    fi
    sleep 1
}

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local prefix="[${CURRENT_STEP}/${TOTAL_STEPS}]"
    if [[ "$HAVE_GUM" == true ]]; then
        gum style --foreground 51 --bold "${prefix} $1"
        gum style --faint "$(printf '─%.0s' $(seq 1 46))"
    else
        echo -e "\n${BOLD}${CYAN}${prefix} $1${RESET}"
    fi
    zen_pause
}

info()  {
    if [[ "$HAVE_GUM" == true ]]; then gum style --faint "    $1"; else echo -e "${DIM}    $1${RESET}"; fi
}
warn()  {
    if [[ "$HAVE_GUM" == true ]]; then gum style --foreground 220 "!!  $1"; else echo -e "${YELLOW}!!  $1${RESET}"; fi
}
ok()    {
    if [[ "$HAVE_GUM" == true ]]; then gum style --foreground 42 "✓   $1"; else echo -e "${GREEN}✓   $1${RESET}"; fi
}
die()   {
    if [[ "$HAVE_GUM" == true ]]; then gum style --foreground 196 --bold "✗ FEHLER: $1"; else echo -e "${RED}✗ FEHLER: $1${RESET}"; fi
    exit 1
}

# Führt einen Befehl aus; zeigt bei vorhandenem gum einen Spinner MIT
# sichtbarer Live-Ausgabe darunter (wichtig für Fehlersuche bei
# pacman/paru — die Ausgabe wird nicht versteckt, nur schöner gerahmt).
run_step() {
    local title="$1"; shift
    if [[ "$HAVE_GUM" == true ]]; then
        gum spin --spinner dot --title "$title" --show-output -- "$@"
    else
        "$@"
    fi
}

# ---------------------------------------------------------------------------
# Vorprüfungen (noch ohne gum, das kommt erst gleich)
# ---------------------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    echo "FEHLER: Bitte NICHT als root ausführen. Als normaler User starten (sudo wird intern genutzt)."
    exit 1
fi

command -v sudo >/dev/null 2>&1 || { echo "FEHLER: sudo ist nicht installiert."; exit 1; }

echo "Verbindung wird geprüft..."
ping -c1 -W2 archlinux.org >/dev/null 2>&1 || { echo "FEHLER: Keine Internetverbindung. Erst WLAN/LAN einrichten (nmtui / iwctl), dann erneut starten."; exit 1; }
echo "Verbindung steht."

# gum aus dem offiziellen Repo holen, BEVOR alles andere läuft — damit
# der Rest der Installation die schönere Oberfläche nutzen kann.
if ! command -v gum >/dev/null 2>&1; then
    echo "Richte Oberfläche ein (gum)..."
    sudo pacman -S --needed --noconfirm gum >/dev/null 2>&1 || true
    command -v gum >/dev/null 2>&1 && HAVE_GUM=true
fi

clear
banner

if [[ "$HAVE_GUM" == true ]]; then
    gum confirm "Bereit, Zazen Linux einzurichten?" || { echo "Abgebrochen."; exit 0; }
fi

ok "Verbindung steht, Oberfläche bereit"

# ---------------------------------------------------------------------------
# Optionale Apps auswählen (Kernpakete Floorp/kitty/VSCodium/HyprMod sind
# immer dabei — hier geht's nur um die "nice to have"-Auswahl)
# ---------------------------------------------------------------------------
declare -A OPTIONAL_APP_PKGS=(
    ["Discord"]="discord"
    ["Spotify"]="spotify"
    ["Boostnote"]="boostnote-bin"
)
SELECTED_OPTIONAL=()
SELECTED_LABELS=()

if [[ "$HAVE_GUM" == true ]]; then
    echo ""
    mapfile -t SELECTED_LABELS < <(gum choose --no-limit \
        --selected="Discord,Spotify,Boostnote" \
        --header "Optionale Apps (Leertaste zum Wählen, Enter zum Bestätigen):" \
        "Discord" "Spotify" "Boostnote")
else
    SELECTED_LABELS=("Discord" "Spotify" "Boostnote")
fi

for label in "${SELECTED_LABELS[@]}"; do
    SELECTED_OPTIONAL+=("${OPTIONAL_APP_PKGS[$label]}")
done

# ---------------------------------------------------------------------------
# 1. System aktualisieren
# ---------------------------------------------------------------------------
step "System wird aktualisiert"
run_step "Systemaktualisierung läuft..." sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------------
# 2. Basis-Pakete + AUR-Helper (paru)
#    Bewusst OHNE firefox/foot — Zazen nutzt Floorp + kitty
# ---------------------------------------------------------------------------
step "Grundlagen werden gelegt (Basis-Pakete)"
run_step "Basis-Pakete werden installiert..." sudo pacman -S --needed --noconfirm \
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
    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (cd "$tmpdir/paru" && makepkg -si --noconfirm)
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
    zen-browser-bin\
    vscodium-bin \
    hyprmod \
    ttf-udev-gothic \
    "${SELECTED_OPTIONAL[@]}"

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

# kitty auf UDEV Gothic NF einstellen — Lateinische Zeichen bleiben normal
# lesbar (basiert auf JetBrains Mono), aber alle Kanji/Symbole bekommen
# den japanischen Look (basiert auf BIZ UD Gothic). Inklusive Nerd-Font-
# Icons für die Caelestia-Statusleiste.
KITTY_CFG_DIR="$HOME/.config/kitty"
KITTY_CFG="$KITTY_CFG_DIR/kitty.conf"
mkdir -p "$KITTY_CFG_DIR"
if [[ -f "$KITTY_CFG" ]] && grep -q "^font_family" "$KITTY_CFG" 2>/dev/null; then
    warn "$KITTY_CFG hat bereits eine font_family — bitte manuell auf 'UDEVGothic NF' prüfen"
else
    cat >> "$KITTY_CFG" << 'EOF'

# Zazen Linux: Japan-Theme-Schrift (Latein bleibt lesbar, Kanji im JP-Look)
font_family      UDEVGothic NF
bold_font        UDEVGothic NF Bold
italic_font      UDEVGothic NF Italic
bold_italic_font UDEVGothic NF Bold Italic
font_size        11.0
EOF
    ok "kitty.conf erstellt (Schrift: UDEVGothic NF)"
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
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
ELAPSED_MIN=$((ELAPSED / 60))
ELAPSED_SEC=$((ELAPSED % 60))

INSTALLED_APPS="VSCodium"
for label in "${SELECTED_LABELS[@]}"; do
    INSTALLED_APPS="${INSTALLED_APPS} · ${label}"
done

echo ""
if [[ "$HAVE_GUM" == true ]]; then
    if [[ "$IS_RAW_TTY" == true ]]; then
        gum style --border double --align center --width 46 --padding "1 2" \
            --border-foreground 42 --foreground 42 --bold \
            "Die Installation ist vollendet." "" "complete" "" "Dauer: ${ELAPSED_MIN}m ${ELAPSED_SEC}s"
    else
        gum style --border double --align center --width 46 --padding "1 2" \
            --border-foreground 42 --foreground 42 --bold \
            "⛩  Die Installation ist vollendet.  ⛩" "" "完成 — kansei" "" "Dauer: ${ELAPSED_MIN}m ${ELAPSED_SEC}s"
    fi
    echo ""
    gum style --border rounded --width 46 --padding "1 2" --border-foreground 51 \
        "Deine Zazen-Ausstattung" \
        "" \
        "Desktop     Hyprland + Caelestia Shell" \
        "Login       SDDM · Japanese Aesthetic" \
        "Browser     Floorp" \
        "Terminal    kitty" \
        "Schrift     UDEVGothic NF" \
        "Shell       fish" \
        "Apps        ${INSTALLED_APPS}" \
        "Extra       HyprMod (grafische Hyprland-Settings)"
else
    echo -e "${CYAN}"
    cat << EOF
                                 ⛩
        ╔══════════════════════════════════════════╗
        ║   Die Installation ist vollendet.        ║
        ║   完成 — kansei                           ║
        ║   Dauer: ${ELAPSED_MIN}m ${ELAPSED_SEC}s                          ║
        ╚══════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    echo -e "${DIM}Desktop:   Hyprland + Caelestia Shell"
    echo -e "Login:     SDDM · Japanese Aesthetic"
    echo -e "Browser:   Floorp"
    echo -e "Terminal:  kitty"
    echo -e "Schrift:   UDEVGothic NF"
    echo -e "Shell:     fish"
    echo -e "Apps:      ${INSTALLED_APPS}"
    echo -e "Extra:     HyprMod (grafische Hyprland-Settings)${RESET}"
fi

info "Neustart: sudo reboot"
info "Standard-Browser: Floorp  |  Standard-Terminal: kitty"
info "Hyprland-Einstellungen anpassen: 'hyprmod' öffnen (grafische Oberfläche, live-Vorschau)"
info "Theme testen ohne Neustart:"
info "  sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/"
echo ""
zen_pause
