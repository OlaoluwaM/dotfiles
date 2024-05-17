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

export NVM_DIR="$HOME/Library/Application Support/nvm"

plugins=(git command-not-found git-escape-magic rand-quote safe-paste sudo zsh-autosuggestions fast-syntax-highlighting you-should-use httpie npm gh zoxide nvm)

zstyle ':omz:plugins:nvm' autoload yes
zstyle ':omz:plugins:nvm' silent-autoload yes

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

if [[ -f "$HOME/.private-shell-env" ]]; then
  source "$HOME/.private-shell-env"
fi

source "$DOTS/shell/smartdots.zsh"

if [[ -f "$DOTS/shell/augment-path-var.sh" ]]; then
  source "$DOTS/shell/augment-path-var.sh"
fi

# Do not override files using `>`, but it's still possible using `>|`
set -o noclobber

# For vscode shell integrations
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Other things to run
# For inspirational Quotes
if command -v hacker-laws-cli &>/dev/null; then
  hacker-laws-cli random
fi

if command -v quote &>/dev/null; then
  echo -e "\r"
  quote
fi

export PATH="/usr/local/bin:$PATH"

# Navi (https://github.com/denisidoro/navi)
eval "$(navi widget zsh)"

# Atuin (https://github.com/ellie/atuin)
eval "$(atuin init zsh)"

# Setup Starship ZSH prompt (https://github.com/starship/starship)
eval "$(starship init zsh)"

eval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(fzf --zsh)"

# pnpm
export PNPM_HOME="/Users/ola.mustapha/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

source /Users/ola.mustapha/.config/broot/launcher/bash/br

[ -f "/Users/ola.mustapha/.ghcup/env" ] && source "/Users/ola.mustapha/.ghcup/env" # ghcup-env
# Created by `pipx` on 2024-03-06 00:33:47
export PATH="$PATH:/Users/ola.mustapha/.local/bin"

export PATH="/opt/homebrew/opt/llvm@12/bin:$PATH"
