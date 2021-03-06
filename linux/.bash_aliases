# To make sure aliases work
alias testAliases='echo Aliases are working'

# Functions
function load_env() {
  RUNNER=${3:-node}
  env $(cat $1 | grep -v "\"#\"" | xargs) $RUNNER $2
}

function does_entity_exist() {
  if test $1 "$3"; then
    echo "${2} ${3} exists"
  else
    echo "${2} ${3} does not exist"
  fi
}

function latest_version() {
  LATEST_LIST=""
  for VAR in $@; do
    LATEST_LIST+="${VAR}@latest "
  done
  npm un $@ && npm i $LATEST_LIST
  echo "Updated the following packages to their latest version: ${@}"
}

function setTimer() {
  TIME="${1:-30m}"

  if [[ "$TERM" =~ "screen".* ]]; then
    echo "Detaching from tmux session..."
    exit
    sleep 40
    echo "Detached from tmux session."

    termdown $TIME
    sleep 15
    tmux new-session -A -s default
    echo "Attached to tmux session"
  else
    termdown $TIME
  fi
  echo "Timer Complete"
}

# eval "$(thefuck --alias fuck)"
# eval $(thefuck --alias --enable-experimental-instant-mode)

# Env Variables
export testVar='testing 123...'
export customTemplateName="theblackuchiha"
export DISPLAY=$(route.exe print | grep 0.0.0.0 | head -1 | awk '{print $4}'):0.0
export LIBGL_ALWAYS_INDIRECT=1

# Actual Aliases
alias latestVersion="latest_version $@"
alias loadEnv=load_env
alias old="npm outdated"
alias findRunningNodeServers="ps -aef | grep node"
alias doesFileExist='does_entity_exist -f File'
alias doesDirExist="does_entity_exist -d Directory"
alias listGlobalPackages="npm -g ls --depth 0"
alias matrix="matrix-rain"
alias commit="git commit"
alias reloadTmuxConfig="tmux source-file ~/.tmux.conf"
alias newTmuxSession="tmux new -s"
alias resetTmuxConfig="tmux show -g | sed 's/^/set -g /' > ~/.tmux.conf"
alias openChrome="~/.winApps/chrome.exe"
alias Spotify="~/.winApps/Spotify.exe"
alias update="sudo ~/wrapper_scripts/update.sh"
alias upgrade="sudo ~/wrapper_scripts/upgrade.sh"
alias checkForUpdate="update;upgrade"
alias cb=clipboard
alias initialPush="git push -u origin"
alias grabFromGithub="curl -LJO"
alias papi_says="sudo"
alias viewFile="wslview"
alias signedCommit="git commit -s"
alias checkInternetSpeed="openChrome fast.com"
alias startTimer="setTimer"
alias wordStore="cat ~/olaolu_dev/dev/word_of_the_day/src/store.json"
alias newRemoteBranch="git push --set-upstream origin"
alias bringOptInHere="cp -r ~/olaolu_dev/dev/optIn_scripts ."
alias bringOptInScriptsHere="cp -r ~/olaolu_dev/dev/optIn_custom_scripts/ ."
alias codeWorkAround="code --disable-gpu"
alias removeDotKeepFiles="find . -name '.keep' -delete"
