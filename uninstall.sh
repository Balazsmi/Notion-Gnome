#!/usr/bin/env bash
set -euo pipefail

APP_ID="notion-gnome"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/notion-gnome"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_FILE="$DESKTOP_DIR/Notion-Gnome.desktop"

echo "Uninstalling $APP_ID..."

# 1. Terminate any running instances before attempting file cleanup
if pgrep -f "firefox.*$DATA_DIR/profile" >/dev/null 2>&1; then
  pkill -f "firefox.*$DATA_DIR/profile" || true
  sleep 0.5
fi

# 2. Purge application data, profile, and launcher files
rm -rf "$DATA_DIR"
rm -f "$DESKTOP_FILE"

# 3. Update the system desktop launcher database
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo "Uninstalled Notion successfully."