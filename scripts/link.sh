#!/usr/bin/env bash
# Symlinks managed dotfiles into $HOME, backing up anything already there.
# Handles two cases per file:
#   * repo copy exists      -> back up any real file in $HOME, then symlink
#   * only $HOME copy exists -> "adopt" it: move into the repo, then symlink
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link_file() {
  local repo_rel="$1" home_target="$2"
  local repo_path="$REPO/$repo_rel"

  # Already correctly linked? Nothing to do.
  if [[ -L "$home_target" && "$(readlink "$home_target")" == "$repo_path" ]]; then
    echo "==> $home_target already linked"
    return
  fi

  # Adopt: repo copy missing but a real file exists in $HOME.
  if [[ ! -e "$repo_path" && -e "$home_target" && ! -L "$home_target" ]]; then
    echo "==> Adopting $home_target into repo ($repo_rel)"
    mkdir -p "$(dirname "$repo_path")"
    mv "$home_target" "$repo_path"
  fi

  # If we still have no repo copy, skip (e.g. .p10k.zsh before `p10k configure`).
  if [[ ! -e "$repo_path" ]]; then
    echo "==> Skipping $repo_rel (no source file yet)"
    return
  fi

  # Back up an existing real file / wrong symlink.
  if [[ -e "$home_target" || -L "$home_target" ]]; then
    echo "==> Backing up $home_target -> ${home_target}.backup-$STAMP"
    mv "$home_target" "${home_target}.backup-$STAMP"
  fi

  ln -s "$repo_path" "$home_target"
  echo "==> Linked $home_target -> $repo_path"
}

link_file "zsh/.zshrc"     "$HOME/.zshrc"
link_file "p10k/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "==> Linking complete"
