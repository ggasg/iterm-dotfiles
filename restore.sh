#!/usr/bin/env bash
# =============================================================================
#  restore.sh — roll back iterm-dotfiles: remove managed symlinks and restore
#  the most recent backup of each file.
#
#  Usage:
#    ./restore.sh              — interactive; prompts before acting
#    ./restore.sh --yes        — skip confirmation prompt
#    ./restore.sh --factory    — also reset iTerm2/GNOME Terminal and tmux to
#                                 factory defaults
#    ./restore.sh --factory --yes
#
#  What it does:
#    1. For each managed file (~/.zshrc, ~/.p10k.zsh, ~/.tmux.conf):
#         a. Removes the symlink created by link.sh (only if it points into
#            this repo — files managed elsewhere are left alone).
#         b. Restores the most recent *.backup-<timestamp> created at install
#            time, if one exists.
#    2. With --factory, additionally:
#         macOS: disconnects iTerm2 from the custom prefs folder and deletes
#                all iTerm2 preferences (full factory reset).
#         Linux: resets GNOME Terminal profiles via `dconf reset`.
#         tmux:  kills the running tmux server so built-in defaults take effect.
#
#  Nothing is lost:
#    * link.sh backs up originals before linking, so your pre-install files
#      are always recoverable here.
#    * The repo itself is untouched — you can re-run install.sh at any time.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY=false
AUTO_YES=false

for arg in "$@"; do
  case "$arg" in
    --factory) FACTORY=true ;;
    --yes|-y)  AUTO_YES=true ;;
  esac
done

# ── Helpers ──────────────────────────────────────────────────────────────────

confirm() {
  $AUTO_YES && return 0
  local prompt="$1"
  read -rp "$prompt [y/N] " yn
  [[ "$yn" =~ ^[Yy]$ ]]
}

# Remove the symlink (only if it was ours) then restore the newest backup.
restore_file() {
  local target="$1" repo_rel="$2" label="$3"
  local repo_path="$REPO/$repo_rel"

  echo ""
  echo "  [$label]"

  # Only remove the symlink if it still points into this repo.
  if [[ -L "$target" ]]; then
    local current_dest
    current_dest="$(readlink "$target")"
    if [[ "$current_dest" == "$repo_path" ]]; then
      rm "$target"
      echo "    removed symlink: $target"
    else
      echo "    skipping — $target points to '$current_dest', not managed by this repo"
      return
    fi
  elif [[ -e "$target" ]]; then
    echo "    skipping — $target exists but is not a symlink (manually managed)"
    return
  else
    echo "    $target not present"
  fi

  # Restore the most recent backup, if any.
  local backup
  backup="$(ls -t "${target}.backup-"* 2>/dev/null | head -1 || true)"
  if [[ -n "$backup" ]]; then
    mv "$backup" "$target"
    echo "    restored: $(basename "$backup") → $target"
  else
    echo "    no pre-install backup found — $label will be absent until you create one"
  fi
}

# ── Banner ────────────────────────────────────────────────────────────────────

echo "==> iterm-dotfiles restore"
echo ""
echo "  Managed files: ~/.zshrc  ~/.p10k.zsh  ~/.tmux.conf"
if $FACTORY; then
  echo "  --factory: will also reset iTerm2 (macOS) / GNOME Terminal (Linux) and tmux to factory defaults"
fi
echo ""
confirm "Proceed?" || { echo "Aborted."; exit 0; }

# ── 1. Dotfile symlinks ───────────────────────────────────────────────────────

echo ""
echo "--- Dotfile symlinks ---"
restore_file "$HOME/.zshrc"     "zsh/.zshrc"     ".zshrc"
restore_file "$HOME/.p10k.zsh"  "p10k/.p10k.zsh" ".p10k.zsh"
restore_file "$HOME/.tmux.conf" "tmux/.tmux.conf" ".tmux.conf"

# ── 2. tmux ───────────────────────────────────────────────────────────────────

echo ""
echo "--- tmux ---"
if $FACTORY; then
  # ~/.tmux.conf is already gone (step 1). Kill the server so the next
  # tmux session starts clean with built-in defaults.
  if command -v tmux >/dev/null 2>&1; then
    if tmux list-sessions &>/dev/null; then
      if confirm "  Kill running tmux server to apply built-in defaults now?"; then
        tmux kill-server 2>/dev/null || true
        echo "  tmux server killed — built-in defaults will apply on next launch"
      else
        echo "  tmux server left running; defaults apply after it restarts"
      fi
    else
      echo "  No active tmux server; built-in defaults apply on next launch"
    fi
  fi
else
  echo "  ~/.tmux.conf removed (see step above)"
  echo "  tmux will use built-in defaults (Ctrl-b prefix, no mouse) on next launch"
  echo "  Tip: use --factory to also kill the running tmux server immediately"
fi

# ── 3. GNOME Terminal (Linux only) ──────────────────────────────────────────

if [[ "$(uname)" == "Linux" ]] && command -v dconf >/dev/null 2>&1; then
  echo ""
  echo "--- GNOME Terminal ---"
  if $FACTORY; then
    if confirm "  Reset GNOME Terminal profiles to factory defaults (dconf reset)?"; then
      dconf reset -f /org/gnome/terminal/ 2>/dev/null || true
      echo "  Done. Open a new GNOME Terminal window to see factory defaults."
      echo ""
      echo "  To restore your saved profile later:"
      echo "    ./scripts/gnome-terminal-load.sh"
    else
      echo "  Skipped."
    fi
  else
    echo "  Skipped (GNOME Terminal profiles are unchanged)."
    echo ""
    echo "  To reset GNOME Terminal to factory defaults, run:"
    echo "    ./restore.sh --factory"
    echo ""
    echo "  Or manually:  dconf reset -f /org/gnome/terminal/"
    echo "  Then reload your saved profile:  ./scripts/gnome-terminal-load.sh"
  fi
fi

# ── 4. iTerm2 (macOS only) ───────────────────────────────────────────────────

if [[ "$(uname)" == "Darwin" ]]; then
  echo ""
  echo "--- iTerm2 ---"
  if $FACTORY; then
    echo "  Disconnecting iTerm2 from the custom preferences folder..."
    defaults delete com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true
    defaults delete com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true
    echo "  Deleting all iTerm2 preferences (factory reset)..."
    defaults delete com.googlecode.iterm2 2>/dev/null || true
    # Flush the preferences cache so changes take effect without a logout.
    killall cfprefsd 2>/dev/null || true
    echo "  Done. Relaunch iTerm2 — it will start with factory defaults."
    echo ""
    echo "  To restore your saved settings later:"
    echo "    defaults import com.googlecode.iterm2 $REPO/iterm2/com.googlecode.iterm2.plist"
    echo "    killall cfprefsd"
  else
    echo "  Skipped (iTerm2 preferences are unchanged)."
    echo ""
    echo "  To perform a full iTerm2 factory reset, run:"
    echo "    ./restore.sh --factory"
    echo ""
    echo "  Or manually:"
    echo "    defaults delete com.googlecode.iterm2 && killall cfprefsd"
    echo "  Then relaunch iTerm2. To re-import your saved settings:"
    echo "    defaults import com.googlecode.iterm2 $REPO/iterm2/com.googlecode.iterm2.plist"
    echo "    killall cfprefsd"
  fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "==> Restore complete."
echo "    Open a new shell (or run: exec zsh) to see the effect."
echo "    To reinstall at any time: ./install.sh"
