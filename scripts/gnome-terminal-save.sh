#!/usr/bin/env bash
# Snapshots the current machine's GNOME Terminal profiles (font, colors,
# palette, default profile) into the repo via dconf.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DUMP="$REPO/gnome-terminal/terminal.dconf"

if ! command -v dconf >/dev/null 2>&1; then
  echo "dconf not found (are you on GNOME?). Install it: sudo apt-get install dconf-cli" >&2
  exit 1
fi

echo "==> Exporting current GNOME Terminal settings"
mkdir -p "$(dirname "$DUMP")"
dconf dump /org/gnome/terminal/ > "$DUMP"
echo "==> Saved to $DUMP"
echo ""
echo "Commit this file to keep your GNOME Terminal profile (font, colors,"
echo "palette) in sync across machines. Load it on another machine with:"
echo "  ./scripts/gnome-terminal-load.sh"
