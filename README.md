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
| `iterm2/` | Custom-preferences folder for iTerm2 (`com.googlecode.iterm2.plist`) + color schemes. macOS only. |
| `gnome-terminal/` | Saved GNOME Terminal profile (`terminal.dconf`: font, colors, palette). Linux only. |
| `Brewfile` | macOS dependencies: `tmux`, `pyenv`, `coursier`, `git`, MesloLGS Nerd Font. |
| `install.sh` | One-shot setup for a fresh machine. Detects the OS and either runs the macOS steps below or delegates to `scripts/install-linux.sh`. |
| `scripts/install-linux.sh` | Ubuntu/Debian equivalent of the macOS steps in `install.sh`: apt packages, pyenv, coursier, Nerd Font, default shell. |
| `sync.sh` | Pull this machine's current config back into the repo before committing. |
| `restore.sh` | Roll back: remove managed symlinks, restore backups, optionally factory-reset iTerm2/GNOME Terminal/tmux. |
| `scripts/` | The individual steps `install.sh` / `install-linux.sh` run. |

## Prerequisites

- macOS, or Ubuntu/Debian (apt-based Linux)
- macOS: [Homebrew](https://brew.sh)
- git

## Set up a new machine

```sh
git clone <your-repo-url> ~/iterm-dotfiles
cd ~/iterm-dotfiles
./install.sh
```

`install.sh` detects the OS: on macOS it runs the Homebrew-based steps below;
on Linux it delegates to `scripts/install-linux.sh` (apt-based — see
[Ubuntu](#ubuntu) below).

### macOS

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

### Ubuntu

`install.sh` delegates to `scripts/install-linux.sh`, which apt-installs
`zsh git curl tmux xclip fontconfig dconf-cli`, installs pyenv (via
`pyenv.run`) and coursier (Linux binary release), downloads the MesloLGS
Nerd Font to `~/.local/share/fonts/`, and sets zsh as your default shell
(`chsh`) before running the same shared `install-omz.sh` / `link.sh` steps
as macOS.

Then finish the interactive bits:

1. Set your terminal's profile font to **MesloLGS Nerd Font**.
2. If you use GNOME Terminal, load a saved profile with
   `./scripts/gnome-terminal-load.sh` (see `gnome-terminal/README.md`), or
   configure it manually and save it with `./scripts/gnome-terminal-save.sh`.
3. Log out and back in (or open a new terminal) to pick up the zsh shell
   and PATH changes from pyenv/coursier.
4. Open a new terminal and run `p10k configure`.
5. Run `./scripts/link.sh` to adopt the new `~/.p10k.zsh` into the repo.
6. Start a tmux session to verify the p10k prompt appears inside it: `tmux new`.
7. `git add -A && git commit -m "Update config"`.

## Saving changes

After tweaking your prompt, aliases, or terminal settings:

```sh
./sync.sh          # refreshes symlinks + exports iTerm2/GNOME Terminal prefs
git add -A && git commit -m "Update config"
git push
```

`sync.sh` exports iTerm2 prefs on macOS or GNOME Terminal's dconf profile on
Linux (if `dconf` is present), whichever applies.

Because `~/.zshrc` and `~/.p10k.zsh` are symlinks into this repo, most edits are
already tracked; `sync.sh` mainly captures iTerm2's plist (unless you use the
custom-folder method, which writes here automatically).

## Before you push (sensitive-info checklist)

The tracked files ship clean — no credentials, emails, or hardcoded usernames;
secrets live in `~/.zshrc.local`, which is git-ignored. But a few files get
generated later on your own machine and are worth a glance before pushing,
especially to a public remote:

- [ ] **`iterm2/com.googlecode.iterm2.plist`** — an exported iTerm2 profile can
      embed SSH/login commands, saved hostnames or usernames, badge text, and
      trigger patterns. Skim it (or open `less iterm2/com.googlecode.iterm2.plist`)
      for anything private.
- [ ] **`gnome-terminal/terminal.dconf`** — same risk as the iTerm2 plist:
      a dumped GNOME Terminal profile can embed a custom title, command, or
      working-directory setting with a hostname or username baked in.
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
| tmux (inside iTerm2 or Linux) | unset / `tmux` | p10k prompt, oh-my-zsh plugins |
| Terminal.app | `Apple_Terminal` | plain shell, no oh-my-zsh |
| GNOME Terminal / other Linux terminal | unset (not `Apple_Terminal`) | p10k prompt, oh-my-zsh plugins |

## Restore / rollback

Every managed file is backed up with a timestamp before it is linked
(`~/.zshrc.backup-<timestamp>`, etc.). To undo this setup entirely:

```sh
./restore.sh           # interactive — removes symlinks, restores backups
./restore.sh --factory # also resets iTerm2/GNOME Terminal and tmux to factory defaults
./restore.sh --yes     # skip the confirmation prompt (combine with --factory)
```

What `restore.sh` does:

| Step | Action |
|---|---|
| Dotfile symlinks | Removes `~/.zshrc`, `~/.p10k.zsh`, `~/.tmux.conf` if they point into this repo; restores the most recent `*.backup-*` for each |
| GNOME Terminal (Linux) | With `--factory`: `dconf reset`s GNOME Terminal profiles to factory defaults; prints the command to reload your saved profile from `gnome-terminal/` |
| tmux | With `--factory`: kills the running server so built-in defaults (Ctrl-b prefix, no mouse) take effect immediately |
| iTerm2 (macOS) | With `--factory`: removes the custom-prefs-folder pointer and deletes all iTerm2 preferences; prints the command to re-import from `iterm2/` |

The repo is never modified — you can always run `./install.sh` again.
