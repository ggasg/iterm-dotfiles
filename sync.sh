#!/usr/bin/env bash
# =============================================================================
#  sync.sh — pull this machine's live config back into the repo before you
#  commit. Run this whenever you've tweaked something and want to save it.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# .zshrc and .p10k.zsh are symlinks into the repo, so edits are already here.
# Running link.sh adopts .p10k.zsh the first time (after `p10k configure`).
bash "$REPO/scripts/link.sh"

if [[ "$(uname)" == "Darwin" ]]; then
  # iTerm2 prefs need an explicit export unless you use the custom-folder method.
  bash "$REPO/scripts/iterm-prefs.sh"
elif command -v dconf >/dev/null 2>&1; then
  bash "$REPO/scripts/gnome-terminal-save.sh"
fi

echo
echo "==> Now review and commit:"
echo "    git -C \"$REPO\" status"
echo "    git -C \"$REPO\" add -A && git -C \"$REPO\" commit -m \"Update config\""
