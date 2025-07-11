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

export NVM_DIR="$HOME/.config/nvm"

plugins=(git command-not-found git-escape-magic rand-quote safe-paste zsh-autosuggestions fast-syntax-highlighting you-should-use gh zoxide nvm direnv)

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

if [[ -f "$DOTS/shell/.private-shell-env" ]]; then
  source "$DOTS/shell/.private-shell-env"
fi

source "$DOTS/shell/smartdots.zsh"

if [[ -f "$DOTS/shell/augment-path-var.sh" ]]; then
  source "$DOTS/shell/augment-path-var.sh"
fi

source "$DOTS/shell/linux-tty-catppuccin-colors.sh"

# Do not override files using `>`, but it's still possible using `>|`
set -o noclobber

# To allow us omit commands prefix with a space from shell history
setopt HIST_IGNORE_SPACE

# For vscode shell integrations
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Other things to run
# For inspirational Quotes
#if command -v hacker-laws-cli &>/dev/null; then
#  hacker-laws-cli random
#fi

#if command -v quote &>/dev/null; then
#  echo -e "\r"
#  quote
#fi

fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

# Atuin (https://github.com/ellie/atuin)
eval "$(atuin init zsh)"

fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

# Setup Starship ZSH prompt (https://github.com/starship/starship)
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# enable the GPG agent to avoid having to type the secret key’s password every time (https://withblue.ink/2020/05/17/how-and-why-to-sign-git-commits.html#cryptographic-signatures-and-gpg)
gpgconf --launch gpg-agent

# Load zsh completions for executables if at least one exists
# https://docs.haskellstack.org/en/stable/shell_autocompletion/
# https://github.com/chubin/cheat.sh?tab=readme-ov-file#zsh-tab-completion
# https://dandavison.github.io/delta/tips-and-tricks/shell-completion.html
if [[ -n "$(ls -A "$XDG_CONFIG_HOME/zsh/completions/")" ]]; then
  fpath=($HOME/.config/zsh/completions $fpath)
  autoload -U compinit && compinit
fi

if command -v batpipe &>/dev/null; then
  eval "$(batpipe)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#https://docs.atuin.sh/reference/gen-completions/
[ -s "$DOTS/shell/completions/_atuin" ] && source "$DOTS/shell/completions/_atuin"
[ -s "$DOTS/shell/completions/aichat.zsh" ] && source "$DOTS/shell/completions/aichat.zsh"
[ -s "$DOTS/shell/completions/navi.zsh" ] && source "$DOTS/shell/completions/navi.zsh"
[ -s "$DOTS/shell/completions/_rip" ] && source "$DOTS/shell/completions/_rip"


[ -f "/home/olaolu/.ghcup/env" ] && . "/home/olaolu/.ghcup/env" # ghcup

eval "$(gh copilot alias -- zsh)"

