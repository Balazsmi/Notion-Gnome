#!/usr/bin/env bash
set -euo pipefail

APP_ID="notion-gnome"
APP_NAME="Notion-Gnome"
APP_URL="https://app.notion.com"

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/notion-gnome"
PROFILE_DIR="$DATA_DIR/profile"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_FILE="$DESKTOP_DIR/Notion-Gnome.desktop"

if ! command -v firefox >/dev/null 2>&1; then
  echo "Firefox is required but was not found in PATH." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$PROFILE_DIR/chrome" "$DESKTOP_DIR"
cp -r "$SCRIPT_DIR/chrome"/* "$PROFILE_DIR/chrome/"

cat > "$PROFILE_DIR/user.js" <<'USERJS'
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.inTitlebar", 1);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.link.open_newwindow", 2);
USERJS

cat > "$DESKTOP_FILE" <<DESKTOP
[Desktop Entry]
Type=Application
Version=1.0
Name=$APP_NAME
Comment=Notion progressive web app with a GNOME-style Firefox titlebar
Exec=env MOZ_ENABLE_WAYLAND=1 firefox --class=$APP_ID --name=$APP_ID --profile=$PROFILE_DIR --no-remote $APP_URL
Icon=notion
StartupWMClass=$APP_NAME
Categories=Office;Network;
Terminal=false
DESKTOP

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo "Installed $APP_NAME."
echo "Launch it from your app menu, or run:"
echo "gtk-launch notion-gnome"
