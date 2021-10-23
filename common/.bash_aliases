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

function pullBranchFromRemote() {
  # $1 is the remote branch name
  # $2 is the remote's name

  git checkout -t "${2:=origin}/${1}"
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

function notify() {
  MESSAGE="${1:="$(date);$(pwd)"}"
  # spd-say 'Done with task!';
  aplay $alarmSound &>/dev/null
  notify-send -u normal -t 7000 $MESSAGE
}

# eval "$(thefuck --alias fuck)"
# eval $(thefuck --alias --enable-experimental-instant-mode)

# Env Variables
export testVar='testing 123...'
export customTemplateName="theblackuchiha"
export alarmSound=$HOME/Music/Windows\ 11\ Sounds/chimes.wav
export gdmThemeLocation=$HOME/customizations/WhiteSur-gtk-theme
export wordStore="/home/olaolu/.nvm/versions/node/v16.7.0/lib/node_modules/term-of-the-day/build/src/wordStore/store.json"

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

alias checkForUpdate="dnf check-update"
alias cb=clipboard
alias initialPush="git push -u origin"

alias grabFromGithub="curl -LJO"
alias signedCommit="git commit -s"
alias newRemoteBranch="git push --set-upstream origin"

alias bringOptInHere="cp -r ~/olaolu_dev/dev/optIn_scripts ."
alias bringOptInScriptsHere="cp -r ~/olaolu_dev/dev/optIn_custom_scripts/ ."
alias codeWorkAround="code --disable-gpu"

alias removeDotKeepFiles="find . -name '.keep' -delete"
alias notion="notion-snap"
alias telegram="telegram-desktop"

alias figma="figma-linux"
alias reloadAliases="source ~/.bash_aliases"
alias plingStore="~/AppImages/pling-store-5.0.2-1-x86_64.AppImage"

alias swag="sudo"
alias editAliases="nano ~/.bash_aliases"
alias tmpmail="~/.tmpmail"

alias listRawVpnLocations="ls /etc/openvpn"
alias listVpnLocations="ls /etc/openvpn | grep "tcp" | cut -d '.' -f 1 | uniq -u"
alias encpass="encpass.sh"

alias editSudoer="sudo EDITOR=$(which nano) visudo"
alias connectToVPN="~/Desktop/olaolu_dev/dev/surfshark_vpn_cli/connectToSurfsharkVPN.sh"
alias notifyMe="notify"

alias checkAutoUpdatesStatus="systemctl list-timers dnf-automatic.timer"
alias loginAsPostgresUser="sudo su - postgres"
alias setLoginScreenWallpaper="sudo $gdmThemeLocation/tweaks.sh -g -b"

alias unlockBitwarden="source ~/Desktop/olaolu_dev/dev/bitwarden_auto_unlock/src/autoUnlockBitwardenVault.sh; bw sync"
alias showRemote="git status -sb"
alias py="python"

alias reloadZSH="omz reload"
alias pvpn="protonvpn-cli"
