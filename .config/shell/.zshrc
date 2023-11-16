######################################################################## OMZ Stuff Start ######################################################################################
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# When installing spaceship with npm, this becomes unnecessary
# Unless we are installing with oh-my-zsh, then this becomes necessary
# If you do not want the spaceship prompt, just re-comment this line
# ZSH_THEME="spaceship"

# When we use certain fonts like JetBrains Mono, this becomes redundant
# if [[ $TERM_PROGRAM = 'vscode' ]]; then SPACESHIP_CHAR_SUFFIX=" "; fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# OMZ Plugins

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# if [[ -f $HOME/.zsh/catppuccin-zsh-syntax-highlighting.zsh ]]; then
#   source "$HOME/.zsh/catppuccin-zsh-syntax-highlighting.zsh"
# fi

plugins=(git command-not-found git-escape-magic rand-quote safe-paste sudo zsh-autosuggestions fast-syntax-highlighting node alias-finder httpie npm gh extract ag zoxide stack yarn)

source "$ZSH/oh-my-zsh.sh"

# User Configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
######################################################################## OMZ Stuff Stop ###################################################################################

if [[ -f "$HOME/.shell-env" ]]; then
  source "$HOME/.shell-env"
fi

if [[ -f "$DOTS/shell/.private-shell-env" ]]; then
  source "$DOTS/shell/.private-shell-env"
fi

source "$DOTS/shell/smartdots.zsh"
# source "$DOTS/shell/nvm-setup.zsh"

if [[ -f "$DOTS/shell/augment-path-var.sh" ]]; then
  source "$DOTS/shell/augment-path-var.sh"
fi

source "$DOTS/shell/linux-tty-catppuccin-colors.sh"

# Do not override files using `>`, but it's still possible using `>|`
set -o noclobber

# For vscode shell integrations
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Other things to run
# For inspirational Quotes
if command -v quote &>/dev/null; then
  echo -e "\r"
  quote
fi

if command -v hacker-laws-cli &>/dev/null; then
  hacker-laws-cli random
fi

# The Fuck (https://github.com/nvbn/thefuck)
eval $(thefuck --alias fuck)

# bun completions
[ -s "/home/olaolu/.oh-my-zsh/completions/_bun" ] && source "/home/olaolu/.oh-my-zsh/completions/_bun"

# Bun (https://github.com/oven-sh/bun)
export BUN_INSTALL="/home/olaolu/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

# Navi (https://github.com/denisidoro/navi)
eval "$(navi widget zsh)"

# Atuin (https://github.com/ellie/atuin)
eval "$(atuin init zsh)"

fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

export PATH=$PATH:/home/olaolu/.spicetify

# Setup Starship ZSH prompt (https://github.com/starship/starship)
eval "$(starship init zsh)"

[ -f "/home/olaolu/.ghcup/env" ] && source "/home/olaolu/.ghcup/env" # ghcup-env

# pnpm
export PNPM_HOME="/home/olaolu/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# enable the GPG agent to avoid having to type the secret key’s password every time (https://withblue.ink/2020/05/17/how-and-why-to-sign-git-commits.html#cryptographic-signatures-and-gpg)
gpgconf --launch gpg-agent

# bun completions
[ -s "/home/olaolu/.bun/_bun" ] && source "/home/olaolu/.bun/_bun"

# FNM https://github.com/Schniz/fnm#shell-setup
eval "$(fnm env --use-on-cd)"

# Add Custom MAN path to $MANPATH
MANPATH=$HOME/.local/share/man:$MANPATH
