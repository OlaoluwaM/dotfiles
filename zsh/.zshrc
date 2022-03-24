# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

ZSH_THEME="spaceship"
SPACESHIP_TIME_SHOW="true"
SPACESHIP_EXIT_CODE_PREFIX=""
SPACESHIP_TIME_FORMAT="%T"
SPACESHIP_TIME_COLOR="white dimmed"
SPACESHIP_EXIT_CODE_SHOW="true"

#SPACESHIP_DIR_PREFIX=" "
if [[ $TERM_PROGRAM = 'vscode' ]]; then SPACESHIP_CHAR_SUFFIX=" "; fi

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

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

if [ -f "$HOME/customizations/dracula/dracula-zsh-syntax-highlighting/zsh-syntax-highlighting.sh" ]; then
  source $HOME/customizations/dracula/dracula-zsh-syntax-highlighting/zsh-syntax-highlighting.sh
fi

plugins=(git command-not-found git-escape-magic rand-quote safe-paste rsync zsh-autosuggestions zsh-syntax-highlighting node)

#if [[ $TERM_PROGRAM != 'vscode' ]]; then
#   ZSH_TMUX_AUTOSTART=true
#   ZSH_TMUX_DEFAULT_SESSION_NAME="senpai"
#fi

source $ZSH/oh-my-zsh.sh

# User configuration

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

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

if [ -f ~/.personal_tokens ]; then
  . ~/.personal_tokens
fi

if [ -f "$HOME/Desktop/olaolu_dev/scripts/ssh-github.sh" ]; then
  source $HOME/Desktop/olaolu_dev/scripts/ssh-github.sh &>/dev/null && [[ $TERM_PROGRAM != 'vscode' ]] && echo
fi

if [ -f "$HOME/Desktop/olaolu_dev/scripts/add-to-path.sh" ]; then
  source $HOME/Desktop/olaolu_dev/scripts/add-to-path.sh --silent
fi

if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# Other things to run

# For colorls (only when ruby is installed)
if gem -v &>/dev/null; then
  source $(dirname $(gem which colorls))/tab_complete.sh
else
  echo "You need to install ruby first :/"
fi

echo "New Day, New Word XD!"

if [ $(command -v quote) ]; then
  quote # For inspirational quotes
else
  echo "Quotes are currently not available\n"
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

if [[ ! -d "$ZSH/completions" || ! -f "$ZSH/completions/_gh" ]]; then
  mkdir -pv $ZSH/completions
  gh completion --shell zsh >$ZSH/completions/_gh
  echo "gh added completions: gh completion --shell zsh > $ZSH/completions/_gh"
fi

# place this after nvm initialization!
# Automatically uses node version specified in .nvmrc file

autoload -U add-zsh-hook
load-nvmrc() {
  printf "\n"
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

if type complete &>/dev/null; then
  _npm_completion() {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
      COMP_LINE="$COMP_LINE" \
      COMP_POINT="$COMP_POINT" \
      npm completion -- "${words[@]}" \
      2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT - 1)) \
      COMP_LINE=$BUFFER \
      COMP_POINT=0 \
      npm completion -- "${words[@]}" \
      2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion() {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
      COMP_LINE="$line" \
      COMP_POINT="$point" \
      npm completion -- "${words[@]}" \
      2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###

# Setup Starship ZSH prompt
#eval "$(starship init zsh)"
#fpath=($fpath "/home/olaolu/.zfunctions")

# The Fuck
eval $(thefuck --alias fuck)
fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt spaceship
export PATH="$PATH:$HOME/.spicetify"
fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")
