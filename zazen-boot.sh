#!/usr/bin/env bash
#
# Zazen Linux — bootstrap
# https://github.com/zenez999/Japan_arch.install
#
# Ein Atemzug genügt, um zu beginnen.

set -euo pipefail

REPO_URL="https://github.com/zenez999/Japan_arch.install.git"
TARGET_DIR="$HOME/.local/share/zazen-linux"

CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

echo -e "${CYAN}⛩  Zazen Linux — Bootstrap${RESET}"
echo -e "${DIM}   座禅 — the art of sitting${RESET}\n"

command -v git >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm git

[[ -d "$TARGET_DIR" ]] && rm -rf "$TARGET_DIR"

echo -e "${DIM}   一期一会 — this moment, once.${RESET}"
git clone --depth 1 "$REPO_URL" "$TARGET_DIR"

chmod +x "$TARGET_DIR/install.sh"
exec "$TARGET_DIR/install.sh"
