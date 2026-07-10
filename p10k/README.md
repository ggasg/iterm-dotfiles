# powerlevel10k config

Your prompt config (`.p10k.zsh`) is personal and generated interactively, so
it isn't shipped here by default. To capture it:

1. In iTerm2, run `p10k configure` and answer the wizard. This writes
   `~/.p10k.zsh`.
2. From the repo root, run `./scripts/link.sh`. It moves that file in here as
   `p10k/.p10k.zsh` and symlinks `~/.p10k.zsh` back to it.
3. Commit. Future edits sync automatically through the symlink.
