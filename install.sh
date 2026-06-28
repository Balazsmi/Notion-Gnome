#!/usr/bin/env bash
set -euo pipefail

APP_ID="notion-gnome"
APP_NAME="Notion"
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

# 1. Aggressively terminate any running instances of this specific PWA
if pgrep -f "firefox.*$PROFILE_DIR" >/dev/null 2>&1; then
  echo "Closing the existing Notion Firefox process so changes take effect..."
  pkill -f "firefox.*$PROFILE_DIR" || true
  sleep 1.5
fi

# 2. Prepare directories
mkdir -p "$DATA_DIR"
mkdir -p "$PROFILE_DIR"
mkdir -p "$DESKTOP_DIR"

# Completely wipe out the old chrome directory inside the profile
rm -rf "$PROFILE_DIR/chrome"

# 3. Copy the chrome styling directory from the workspace
if [ -d "$SCRIPT_DIR/chrome" ]; then
  cp -r "$SCRIPT_DIR/chrome" "$PROFILE_DIR/chrome"
  echo "Chrome styles (userChrome.css) successfully copied to profile."
else
  echo "Error: '$SCRIPT_DIR/chrome' directory not found in your workspace!" >&2
  exit 1
fi

# 4. Copy the icon from the repository to the data directory
ICON_PATH="$DATA_DIR/icon.png"
if [ -f "$SCRIPT_DIR/icons/notion-icon.png" ]; then
  mkdir -p "$(dirname "$ICON_PATH")"
  cp "$SCRIPT_DIR/icons/notion-icon.png" "$ICON_PATH"
else
  ICON_PATH="notion"
fi

# 5. Write Firefox configuration preferences (user.js)
cat > "$PROFILE_DIR/user.js" <<'USERJS'
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.inTitlebar", 1);
user_pref("browser.tabs.warnOnClose", false);

/* --- FORCE ALL LINKS TO OPEN IN THE SAME TAB --- */
user_pref("browser.link.open_newwindow", 1);
user_pref("browser.link.open_newwindow.restriction", 0);
user_pref("browser.link.open_newwindow.override.external", 1);

/* --- CTRL + W CLOSES THE ENTIRE APPLICATION WINDOW --- */
user_pref("browser.tabs.closeWindowWithLastTab", true);

/* --- BLOCK FIRST-RUN, PRIVACY, AND WELCOME TABS --- */
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);

/* --- PREVENT AUTOMATIC IMPORT OF DISTRO-SPECIFIC BOOKMARKS --- */
user_pref("browser.bookmarks.restore_default_bookmarks", false);

/* --- COMPLETELY DISABLE SPELLCHECKING --- */
user_pref("layout.spellcheckDefault", 0);

/* --- REMOVE CONTEXT MENU "ASK AI" CHATBOT REMNANTS --- */
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.shortcuts", false);

/* --- DISABLE FIREFOX TIPS, PROMOS & ONBOARDING SYSTEM --- */
user_pref("browser.maintaining.tips.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.vpn_promo.enabled", false);
user_pref("identity.fxaccounts.enabled", false);

/* --- PREVENT CRASH / SESSION RESTORE POPUPS AND DROPDOWNS --- */
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.sessionstore.max_resumed_crashes", 0);
user_pref("browser.sessionstore.max_tabs_undo", 0);
user_pref("browser.sessionstore.max_windows_undo", 0);
USERJS

# Sanitize an existing prefs.js if present to avoid conflicting values
if [ -f "$PROFILE_DIR/prefs.js" ]; then
  sed -i '/layout.spellcheckDefault/d' "$PROFILE_DIR/prefs.js"
  sed -i '/browser.ml.chat/d' "$PROFILE_DIR/prefs.js"
  sed -i '/browser.tabs.closeWindowWithLastTab/d' "$PROFILE_DIR/prefs.js"
  sed -i '/browser.startup.homepage_override/d' "$PROFILE_DIR/prefs.js"
  sed -i '/browser.link.open_newwindow/d' "$PROFILE_DIR/prefs.js"
  sed -i '/browser.bookmarks.restore_default_bookmarks/d' "$PROFILE_DIR/prefs.js"
  echo 'user_pref("layout.spellcheckDefault", 0);' >> "$PROFILE_DIR/prefs.js"
  echo 'user_pref("browser.ml.chat.enabled", false);' >> "$PROFILE_DIR/prefs.js"
  echo 'user_pref("browser.tabs.closeWindowWithLastTab", true);' >> "$PROFILE_DIR/prefs.js"
  echo 'user_pref("browser.startup.homepage_override.mstone", "ignore");' >> "$PROFILE_DIR/prefs.js"
  echo 'user_pref("browser.link.open_newwindow", 1);' >> "$PROFILE_DIR/prefs.js"
  echo 'user_pref("browser.bookmarks.restore_default_bookmarks", false);' >> "$PROFILE_DIR/prefs.js"
fi

# 6. Generate the .desktop launcher file
cat > "$DESKTOP_FILE" <<DESKTOP
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=Notion progressive web app with a GNOME-style Firefox titlebar
Exec=env MOZ_ENABLE_WAYLAND=1 firefox --class=$APP_ID --name=$APP_ID --profile=$PROFILE_DIR --no-remote $APP_URL
Icon=$ICON_PATH
StartupWMClass=$APP_ID
Categories=Office;Network;
Terminal=false
StartupNotify=true
Keywords=notion;notes;pwa;workspace;text;
MimeType=x-scheme-handler/notion;
SingleMainWindow=true
DESKTOP

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo "--------------------------------------------------"
echo "Installed $APP_NAME successfully."