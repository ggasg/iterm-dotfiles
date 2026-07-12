#!/usr/bin/env bash
# =============================================================================
#  install.sh — set up this iTerm2 + zsh environment on a fresh Mac.
#  Idempotent: safe to run more than once.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

echo "==> iterm-dotfiles install starting"

# --- 0. Sanity: macOS + Homebrew ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "This is intended for macOS." >&2
  exit 1
fi
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it first: https://brew.sh" >&2
  exit 1
fi

# --- 1. Homebrew packages (pyenv, coursier, Nerd Font, git) ---
echo "==> Installing Homebrew dependencies (brew bundle)"
brew bundle --file="$REPO/Brewfile"

# --- 2. Scala/JVM toolchain via coursier ---
if command -v cs >/dev/null 2>&1; then
  echo "==> Running coursier setup"
  cs setup --yes
fi

# --- 3. oh-my-zsh + powerlevel10k + plugins ---
bash "$REPO/scripts/install-omz.sh"

# --- 4. Symlink dotfiles (.zshrc, and .p10k.zsh once it exists) ---
bash "$REPO/scripts/link.sh"

# --- 5. Machine-local file ---
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$REPO/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "==> Created ~/.zshrc.local (edit it for machine-specific settings)"
fi

cat <<EOF

==> Core install complete.

Finish up:
  1. Set the iTerm2 profile font to "MesloLGS Nerd Font"
     (Settings -> Profiles -> Text -> Font).
  2. Import your iTerm2 settings:  ./scripts/iterm-prefs.sh
     (or point iTerm2's custom-prefs folder at ./iterm2 — see README).
  3. Open a new iTerm2 tab and run:  p10k configure
  4. Then run:  ./scripts/link.sh    (adopts the new ~/.p10k.zsh into the repo)
  5. Start tmux to verify the prompt works inside it:  tmux new
  6. Commit:  git add -A && git commit -m "Update config"

Verify: run  echo \$TERM_PROGRAM  in each app.
  iTerm2       -> p10k prompt with git/python/scala context
  tmux (in iTerm2) -> same p10k prompt (oh-my-zsh loads because TERM_PROGRAM != Apple_Terminal)
  Terminal.app -> plain profile, no oh-my-zsh

To undo this install and restore your previous config:
  ./restore.sh
EOF
