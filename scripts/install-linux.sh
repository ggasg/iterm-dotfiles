#!/usr/bin/env bash
# =============================================================================
#  scripts/install-linux.sh — set up this zsh + tmux environment on a fresh
#  Ubuntu/Debian machine. Idempotent: safe to run more than once.
#  Invoked by install.sh when `uname` == Linux; can also be run directly.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

echo "==> iterm-dotfiles Linux install starting"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script expects apt-get (Debian/Ubuntu). Adapt it for your distro." >&2
  exit 1
fi

# --- 1. apt packages ---
echo "==> Installing apt dependencies"
sudo apt-get update
sudo apt-get install -y zsh git curl tmux xclip fontconfig dconf-cli

# --- 2. Python (pyenv) ---
if [[ ! -d "$HOME/.pyenv" ]]; then
  echo "==> Installing pyenv"
  curl -fsSL https://pyenv.run | bash
else
  echo "==> pyenv already installed, skipping"
fi

# --- 3. Scala/JVM toolchain (coursier Linux binary) ---
if ! command -v cs >/dev/null 2>&1; then
  echo "==> Installing coursier"
  cs_bin="$HOME/.local/bin/cs"
  mkdir -p "$(dirname "$cs_bin")"
  curl -fL -o "$cs_bin.gz" https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz
  gunzip -f "$cs_bin.gz"
  chmod +x "$cs_bin"
  export PATH="$HOME/.local/bin:$PATH"
fi
if command -v cs >/dev/null 2>&1; then
  echo "==> Running coursier setup"
  cs setup --yes
fi

# --- 4. MesloLGS Nerd Font (same font iTerm2 side uses, for p10k glyphs) ---
FONT_DIR="$HOME/.local/share/fonts"
if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
  echo "==> Installing MesloLGS Nerd Font"
  mkdir -p "$FONT_DIR"
  base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
  for variant in Regular Bold Italic "Bold Italic"; do
    curl -fsSL -o "$FONT_DIR/MesloLGS NF $variant.ttf" \
      "$base_url/MesloLGS%20NF%20${variant// /%20}.ttf"
  done
  fc-cache -f "$FONT_DIR"
else
  echo "==> MesloLGS Nerd Font already installed, skipping"
fi
echo "    Set your terminal's profile font to \"MesloLGS Nerd Font\" for p10k glyphs."

# --- 5. Default shell ---
zsh_path="$(command -v zsh)"
if [[ "$SHELL" != "$zsh_path" ]]; then
  echo "==> Setting default shell to zsh (you may be prompted for your password)"
  chsh -s "$zsh_path" || echo "    chsh failed — run it manually: chsh -s $zsh_path"
else
  echo "==> zsh already the default shell"
fi

# --- 6. oh-my-zsh + powerlevel10k + plugins (shared with macOS) ---
bash "$REPO/scripts/install-omz.sh"

# --- 7. Symlink dotfiles (shared with macOS) ---
bash "$REPO/scripts/link.sh"

# --- 8. Machine-local file ---
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  cp "$REPO/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "==> Created ~/.zshrc.local (edit it for machine-specific settings)"
fi

cat <<EOF

==> Core install complete.

Finish up:
  1. Set your terminal profile's font to "MesloLGS Nerd Font".
  2. If using GNOME Terminal, load the saved profile:
       ./scripts/gnome-terminal-load.sh
     (or configure it manually — see gnome-terminal/README.md).
  3. Log out and back in (or start a new terminal) to pick up the zsh shell
     and PATH changes from coursier/pyenv.
  4. Open a new terminal and run:  p10k configure
  5. Then run:  ./scripts/link.sh    (adopts the new ~/.p10k.zsh into the repo)
  6. Start tmux to verify the prompt works inside it:  tmux new
  7. Commit:  git add -A && git commit -m "Update config"

Verify: run  echo \$TERM_PROGRAM  — it should be unset/empty on Linux, which
is fine: the zsh gate is \$TERM_PROGRAM != "Apple_Terminal", so oh-my-zsh loads.

To undo this install and restore your previous config:
  ./restore.sh
EOF
