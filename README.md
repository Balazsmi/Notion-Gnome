# Notion-Gnome

A Firefox-based Notion PWA styled to look like a GNOME GTK4 application.

This repo packages the Notion app launcher, an isolated Firefox profile, and custom Firefox chrome styles for `https://app.notion.com`.

## Features

- Isolated Firefox profile so your personal Firefox settings are not changed
- GNOME-style titlebar with:
  - native-looking `Notion` title text
  - GNOME-style back/forward buttons
  - right-aligned window controls
  - hidden tabs/address bar UI
- Optional `userContent.css` to disable Firefox spellcheck UI if needed

## Requirements

- Firefox
- GNOME or another Linux desktop with `.desktop` support

## Install

```bash
git clone https://github.com/YOUR_USERNAME/Notion-Gnome.git
cd Notion-Gnome
./install.sh
```

Then launch **Notion-Gnome** from your application menu.

## Uninstall

```bash
./uninstall.sh
```

## Repo files

This repository includes a launcher file for your app at:

- `Notion-Gnome.desktop`

This repository is self-contained and does not depend on WebAppHub.

The repo launcher template uses the repo-managed profile path:

- Profile path: `$HOME/.local/share/notion-gnome/profile`
- URL: `https://app.notion.com`

`Notion-Gnome.desktop` in this repo is the launcher template that the install script will create for your system.

## Work in this repo

Edit the PWA UI and behavior in these files:

- `chrome/userChrome.css` — GNOME-style topbar, title, navigation buttons, and window controls
- `chrome/userContent.css` — page content tweaks, spellcheck, and other web styling
- `install.sh` — install the repo-managed profile and launcher
- `uninstall.sh` — remove the repo-installed PWA

When you are ready to test your changes, run:

```bash
./install.sh
```

Then launch the installed app from the desktop menu.

The `chrome/` directory in this repository is copied into the PWA profile at `~/.local/share/notion-gnome/profile/chrome/` when you run `install.sh`.

This repo is designed for the Notion PWA only and will not modify your regular Firefox profile unless you run `install.sh`.
