#!/usr/bin/env bash
# Loads the repo's saved GNOME Terminal profile (font, colors, palette) into
# dconf on this machine. Overwrites any existing GNOME Terminal profiles at
# /org/gnome/terminal/ — back them up first if you want to keep them.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DUMP="$REPO/gnome-terminal/terminal.dconf"

if ! command -v dconf >/dev/null 2>&1; then
  echo "dconf not found (are you on GNOME?). Install it: sudo apt-get install dconf-cli" >&2
  exit 1
fi
if [[ ! -f "$DUMP" ]]; then
  echo "No saved profile at $DUMP yet." >&2
  echo "Configure GNOME Terminal the way you want it, then run:" >&2
  echo "  ./scripts/gnome-terminal-save.sh" >&2
  exit 1
fi

echo "==> Loading GNOME Terminal settings from $DUMP"
echo "    This replaces existing profiles under /org/gnome/terminal/."
read -rp "Proceed? [y/N] " yn
if [[ ! "$yn" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

dconf load /org/gnome/terminal/ < "$DUMP"
echo "==> Done. Open a new GNOME Terminal window to see the profile."
