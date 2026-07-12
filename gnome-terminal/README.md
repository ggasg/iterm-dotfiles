# GNOME Terminal settings

GNOME Terminal has no config file to symlink — its profiles (font, colors,
palette, default profile) live in `dconf`. This folder carries a snapshot of
that instead, the same idea as `iterm2/`'s manual-snapshot method.

## Save (on the machine with the profile you want)

```sh
../scripts/gnome-terminal-save.sh
```

Dumps `/org/gnome/terminal/` into `terminal.dconf` in this folder. Commit the
result.

## Load (on a new machine)

```sh
../scripts/gnome-terminal-load.sh
```

Loads `terminal.dconf` back into dconf. This **overwrites** any existing
GNOME Terminal profiles on the target machine — back yours up first
(`../scripts/gnome-terminal-save.sh` before loading, if you want a copy) if
you've customized it there.

`install-linux.sh` does not run this automatically since it would clobber an
existing profile without asking; run it yourself after install.

## Manual equivalent

```sh
dconf dump /org/gnome/terminal/ > terminal.dconf     # save
dconf load /org/gnome/terminal/ < terminal.dconf     # load
```
