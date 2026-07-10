#!/usr/bin/env bash
# Installs oh-my-zsh + powerlevel10k + external plugins. Safe to re-run.
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- oh-my-zsh (--keep-zshrc so it never touches our managed .zshrc) ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing oh-my-zsh"
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
else
  echo "==> oh-my-zsh already installed, skipping"
fi

# --- powerlevel10k theme ---
p10k_dir="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ ! -d "$p10k_dir" ]]; then
  echo "==> Installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
else
  echo "==> powerlevel10k already installed, skipping"
fi

# --- external plugins ---
clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM/plugins/$1"
  if [[ ! -d "$dest" ]]; then
    echo "==> Installing plugin: $name"
    git clone --depth=1 "$url" "$dest"
  else
    echo "==> Plugin $name already installed, skipping"
  fi
}
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

echo "==> oh-my-zsh setup complete"
