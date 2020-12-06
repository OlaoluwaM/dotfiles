# To make sure aliases work
alias test="echo Aliases are working"

# Functions
function load_env () {
  RUNNER=${3:-node}
  env $(cat $1 | grep -v "\"#\"" | xargs) $RUNNER $2
}

function does_entity_exist () {
  if [ $1 "$3" ]; then
    echo "${2} ${3} exists"
  else
    echo "${2} ${3} does not exist"
  fi
}

function latest_version () {
  LATEST_LIST=""
  for VAR in $@; do
  LATEST_LIST+="${VAR}@latest "
  done
  npm un $@ && npm i $LATEST_LIST
  echo "Updated the following packages to their latest version: ${@}"
}

# eval "$(thefuck --alias fuck)"

# Env Variables

export testVar='testing 123...'
export FORCE_COLOR=1
export NODE_PATH="$(npm root -g)"


# Actual Aliases
alias latestVersion="latest_version $@"
alias loadEnv=load_env
alias ..="cd ..${@}"
alias old="npm outdated $1"
alias findRunningNodeServers="ps -aef | grep node"
alias doesFileExist="does_entity_exist -f File $1"
alias doesDirExist="does_entity_exist -d Directory $1"
alias listGlobalPackages="npm -g ls --depth 0"
alias matrix="matrix-rain"
alias pyInstall="python -m pip install $1"
alias reloadTmuxConfig="tmux source-file ~/.tmux.conf"
alias newTmuxSession="tmux new -s $1"
alias resetTmuxConfig="tmux show -g | sed 's/^/set -g /' > ~/.tmux.conf"
