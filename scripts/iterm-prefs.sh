#!/usr/bin/env bash
# Snapshots the current machine's iTerm2 preferences into the repo.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLIST="$REPO/iterm2/com.googlecode.iterm2.plist"

echo "==> Exporting current iTerm2 preferences"
defaults export com.googlecode.iterm2 "$PLIST"
echo "==> Saved to $PLIST"

cat <<EOF

Next steps to keep iTerm2 in sync via this repo:

  1. Open iTerm2 -> Settings -> General -> Preferences.
  2. Tick "Load preferences from a custom folder or URL".
  3. Set the folder to:  $REPO/iterm2
  4. When prompted, choose to copy existing settings to that folder.
  5. Set the save option to save changes when iTerm2 quits.

From then on, iTerm2 reads and writes its plist inside the repo, so a
git commit captures every future tweak automatically.

On a NEW machine after cloning: do the same (steps 1-3) pointing at the
same folder, then relaunch iTerm2 — it will load these settings.
EOF
