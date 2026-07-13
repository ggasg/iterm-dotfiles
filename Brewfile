# Brewfile — install everything with:  brew bundle --file=Brewfile
#
# (install.sh runs this for you)

# --- Coursier tap for the Scala/JVM toolchain ---
tap "coursier/formulas"

# --- CLI tools (available in BOTH terminals) ---
brew "git"
brew "pyenv"        # Python version management
brew "coursier"     # Scala/JVM installer; run `cs setup` afterwards
brew "tmux"         # terminal multiplexer

# --- Nerd Font required by powerlevel10k glyphs ---
cask "font-meslo-lg-nerd-font"

# --- JDK — dedicated Azul Zulu cask, NOT the "openjdk" formula ---
# zsh/.zshrc pins JAVA_HOME to whatever java_home resolves for v21.
cask "zulu@21"
