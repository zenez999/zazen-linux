#!/usr/bin/env bash
#
# Grimoire OS — bootstrap
# https://github.com/zenez999/grimoire-os
#
# A long journey, taken slowly.

set -euo pipefail

REPO_URL="https://github.com/zenez999/grimoire-os.git"
TARGET_DIR="$HOME/.local/share/grimoire-os"

CYAN='\033[0;36m'
DIM='\033[2m'
RESET='\033[0m'

echo -e "${CYAN}Grimoire OS — Bootstrap${RESET}"
echo -e "${DIM}   a long journey, taken slowly${RESET}\n"

command -v git >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm git

[[ -d "$TARGET_DIR" ]] && rm -rf "$TARGET_DIR"

git clone --depth 1 "$REPO_URL" "$TARGET_DIR"

chmod +x "$TARGET_DIR/install.sh"
exec "$TARGET_DIR/install.sh"
