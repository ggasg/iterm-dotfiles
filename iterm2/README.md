# iTerm2 settings

Two ways to carry iTerm2 settings between machines. The custom-folder method is
recommended because it keeps syncing automatically.

## Recommended: custom preferences folder
1. iTerm2 -> Settings -> General -> Preferences.
2. Tick "Load preferences from a custom folder or URL".
3. Point it at this `iterm2/` folder.
4. Copy existing settings when prompted; set it to save on quit.

iTerm2 then reads/writes `com.googlecode.iterm2.plist` right here, so committing
captures every change.

## Alternative: manual snapshot
Run `../scripts/iterm-prefs.sh` to export the current plist into this folder.
To load it on a new machine:

    defaults import com.googlecode.iterm2 iterm2/com.googlecode.iterm2.plist
    killall cfprefsd        # then relaunch iTerm2

## colors/
Drop any `.itermcolors` scheme files here for reference. If you selected a
preset in iTerm2, the active colors are already inside the plist above.
