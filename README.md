# iterm-dotfiles

My iTerm2 + zsh setup, packaged so I can drop it onto any Mac and get the same
look and feel in a few minutes.

The core idea: **oh-my-zsh, powerlevel10k, and plugins load only inside iTerm2**;
the stock **macOS Terminal.app stays clean** and just runs the shared config.
This is done by gating the oh-my-zsh block on `$TERM_PROGRAM == "iTerm.app"` in
`zsh/.zshrc`.

## What's inside

| Path | Purpose |
|------|---------|
| `zsh/.zshrc` | The managed shell config. Shared section runs everywhere; oh-my-zsh block is iTerm2-only. Symlinked to `~/.zshrc`. |
| `zsh/.zshrc.local.example` | Template for per-machine settings/secrets. Copied to `~/.zshrc.local` (git-ignored). |
| `p10k/` | Where your `~/.p10k.zsh` prompt config gets adopted. |
| `iterm2/` | Custom-preferences folder for iTerm2 (`com.googlecode.iterm2.plist`) + color schemes. |
| `Brewfile` | Dependencies: `pyenv`, `coursier`, `git`, MesloLGS Nerd Font. |
| `install.sh` | One-shot setup for a fresh machine. |
| `sync.sh` | Pull this machine's current config back into the repo before committing. |
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
5. `git add -A && git commit -m "Update config"`.

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

## Verify the split works

Run this in each app:

```sh
echo $TERM_PROGRAM
```

- **iTerm2** (`iTerm.app`): powerlevel10k prompt with git/python/scala context.
- **Terminal.app** (`Apple_Terminal`): your plain profile, no oh-my-zsh.

## Restore

Every managed file is backed up before it's replaced. To roll back a machine,
restore the newest `~/.zshrc.backup-*` over `~/.zshrc`.
