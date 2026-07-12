# iterm-dotfiles

My iTerm2 + tmux + zsh setup, packaged so I can drop it onto any Mac and get
the same look and feel in a few minutes.

The core idea: **oh-my-zsh, powerlevel10k, and plugins load everywhere except
macOS Terminal.app** — including inside tmux panes. The stock Terminal.app stays
clean and fast. This is done by gating the oh-my-zsh block on
`$TERM_PROGRAM != "Apple_Terminal"` in `zsh/.zshrc`.

## What's inside

| Path | Purpose |
|------|---------|
| `zsh/.zshrc` | Managed shell config. Shared section runs everywhere; oh-my-zsh block skips Terminal.app only. Symlinked to `~/.zshrc`. |
| `zsh/.zshrc.local.example` | Template for per-machine settings/secrets. Copied to `~/.zshrc.local` (git-ignored). |
| `p10k/` | Where your `~/.p10k.zsh` prompt config gets adopted. |
| `tmux/.tmux.conf` | tmux config: true-color, vi copy-mode, cross-platform clipboard, minimal status bar. Symlinked to `~/.tmux.conf`. |
| `iterm2/` | Custom-preferences folder for iTerm2 (`com.googlecode.iterm2.plist`) + color schemes. |
| `Brewfile` | Dependencies: `tmux`, `pyenv`, `coursier`, `git`, MesloLGS Nerd Font. |
| `install.sh` | One-shot setup for a fresh machine. |
| `sync.sh` | Pull this machine's current config back into the repo before committing. |
| `restore.sh` | Roll back: remove managed symlinks, restore backups, optionally factory-reset iTerm2/tmux. |
| `scripts/` | The individual steps `install.sh` runs. |

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)
- git

## Set up a new machine

```sh
git clone <your-repo-url> ~/iterm-dotfiles
cd ~/iterm-dotfiles
./install.sh
```

Then finish the interactive bits:

1. Set the iTerm2 profile font to **MesloLGS Nerd Font**
   (Settings -> Profiles -> Text -> Font) so p10k glyphs render.
2. Load your iTerm2 settings — point iTerm2's custom-prefs folder at `iterm2/`
   (see `iterm2/README.md`), or run `./scripts/iterm-prefs.sh`.
3. Open a new iTerm2 tab and run `p10k configure`.
4. Run `./scripts/link.sh` to adopt the new `~/.p10k.zsh` into the repo.
5. Start a tmux session to verify the p10k prompt appears inside it: `tmux new`.
6. `git add -A && git commit -m "Update config"`.

`install.sh` backs up any existing `~/.zshrc` / `~/.p10k.zsh` to
`*.backup-<timestamp>` before linking, so nothing is lost.

## Saving changes

After tweaking your prompt, aliases, or iTerm2 settings:

```sh
./sync.sh          # refreshes symlinks + exports iTerm2 prefs
git add -A && git commit -m "Update config"
git push
```

Because `~/.zshrc` and `~/.p10k.zsh` are symlinks into this repo, most edits are
already tracked; `sync.sh` mainly captures iTerm2's plist (unless you use the
custom-folder method, which writes here automatically).

## Before you push (sensitive-info checklist)

The tracked files ship clean — no credentials, emails, or hardcoded usernames;
secrets live in `~/.zshrc.local`, which is git-ignored. But two files get
generated later on your own machine and are worth a glance before pushing,
especially to a public remote:

- [ ] **`iterm2/com.googlecode.iterm2.plist`** — an exported iTerm2 profile can
      embed SSH/login commands, saved hostnames or usernames, badge text, and
      trigger patterns. Skim it (or open `less iterm2/com.googlecode.iterm2.plist`)
      for anything private.
- [ ] **`p10k/.p10k.zsh`** — usually safe, but a customized prompt can hardcode
      a username or host in the context segment.
- [ ] Confirm nothing secret landed in the tracked `zsh/.zshrc` — real secrets
      and per-machine values belong in `~/.zshrc.local` (git-ignored), not here.
- [ ] `git status` shows no `*.local` or `*.backup-*` files staged (they're
      git-ignored, but worth a look).

Quick scan for common leaks before committing:

```sh
git grep -niE '(api[_-]?key|secret|password|token|ghp_|sk-|aws_)' -- . ':!*.example'
```

## tmux

`~/.tmux.conf` is symlinked from `tmux/.tmux.conf` and is version-controlled
with everything else. Key features:

- **True color** passthrough — p10k gradients and Nerd Font glyphs render
  correctly inside tmux, just like in a bare iTerm2 window.
- **Prefix**: `Ctrl-a` (easier to reach than the default `Ctrl-b`).
  Revert by commenting out the three `prefix` lines in `tmux/.tmux.conf`.
- **Splits**: `prefix |` (horizontal) / `prefix -` (vertical), both inheriting
  the current working directory.
- **Pane navigation**: `prefix h/j/k/l` (Vim-style).
- **Vi copy mode**: `v` to start selection, `y` to yank to clipboard.
  Clipboard is platform-aware: `pbcopy` on macOS, `xsel`/`xclip`/`wl-copy`
  on Linux.
- **Status bar**: session name on the left, time + date on the right.
  Colors use xterm-256 indices so they adapt to any terminal theme.
  Customize the `colour*` values in `tmux/.tmux.conf` to match your iTerm2
  color scheme.

To reload the config without restarting: `prefix r`.

## Verify the split works

Run this in each environment:

```sh
echo $TERM_PROGRAM
```

| Environment | Value | Result |
|---|---|---|
| iTerm2 | `iTerm.app` | p10k prompt, oh-my-zsh plugins |
| tmux (inside iTerm2) | unset / `tmux` | p10k prompt, oh-my-zsh plugins |
| Terminal.app | `Apple_Terminal` | plain shell, no oh-my-zsh |

## Restore / rollback

Every managed file is backed up with a timestamp before it is linked
(`~/.zshrc.backup-<timestamp>`, etc.). To undo this setup entirely:

```sh
./restore.sh           # interactive — removes symlinks, restores backups
./restore.sh --factory # also resets iTerm2 and tmux to factory defaults
./restore.sh --yes     # skip the confirmation prompt (combine with --factory)
```

What `restore.sh` does:

| Step | Action |
|---|---|
| Dotfile symlinks | Removes `~/.zshrc`, `~/.p10k.zsh`, `~/.tmux.conf` if they point into this repo; restores the most recent `*.backup-*` for each |
| tmux | With `--factory`: kills the running server so built-in defaults (Ctrl-b prefix, no mouse) take effect immediately |
| iTerm2 (macOS) | With `--factory`: removes the custom-prefs-folder pointer and deletes all iTerm2 preferences; prints the command to re-import from `iterm2/` |

The repo is never modified — you can always run `./install.sh` again.
