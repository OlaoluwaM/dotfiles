#!/usr/bin/env bash

# To make sure aliases work
alias testAliases='echo Aliases are working'

# Functions
function load_env() {
  RUNNER=${3:-node}
  env "$(cat $1 | grep -v "\"#\"" | xargs) $RUNNER $2"
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

function pullBranchFromRemoteThenCheckout() {
  git fetch "${1:=origin}" "$2";
  git checkout "$2"
}

function showTerminalColors() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

function notify() {
  MESSAGE="${1:="$(date);$(pwd)"}"
  # spd-say 'Done with task!';
  aplay $alarmSound &>/dev/null
  notify-send -u normal -t 7000 $MESSAGE
}

function newRemoteBranch() {
  branchName="${1:=HEAD}"
  remote="${2:=origin}"

  #echo $remote $branchName
  git push -u $remote $branchName
}

function netSpeed() {
  echo "From speedtest.net";
  speedtest-cli;
  echo "\n";
  echo "From fast.com";
  fast;
}

function reinstallAsDevDep() {
  package="$1"

  npm un $package && npm i -D $package
}

function reinstallAsDep() {
  package="$1"

  npm un $package && npm i $package
}

function backupFonts() {
  echo "Compressing fonts into tarball"
  tar cvzf $SYS_BAK_DIR/fonts.tar.gz $FONT_DIR;
}

function backupWallpapers() {
  currentDir=$(pwd)
  ImagesDir="$HOME/Pictures/Wallpapers"

  cd "$ImagesDir" || return;
  $(which node) compressWallpapers.mjs;
  cd "$currentDir" || return;
}

function downloadFile() {
  URL="$1"
  FILE_NAME="$2"
  echo -e "\n"

  if command -v http &>/dev/null; then
    if [ -z "$FILE_NAME" ]; then
      http -d "$URL"
    else
      http -d "$URL" -o "$FILE_NAME"
    fi

  elif command -v curl &>/dev/null; then
    echo -e "Seems like httpie is not installed...Using curl instead\n"

    if [ -z "$FILE_NAME" ]; then
      curl -LJO "$URL"
    else
      curl -LJo "$FILE_NAME" "$URL"
    fi

  elif command -v wget &>/dev/null; then
    echo -e "Seems like curl is not installed. Let's try wget\n"

    if [ -z "$FILE_NAME" ]; then
      wget "$URL"
    else
      wget -O "$FILE_NAME" "$URL"
    fi

  else
    echo "Seems like neither httpie, curl, or wget are available. Please download one of them first!"
    exit 126
  fi
}

# Env Variables
export customTemplateName="theblackuchiha"
export alarmSound=$HOME/Music/Windows\ 11\ Sounds/chimes.wav
export ALIASES="$HOME/.bash_aliases"

export wordStore="/home/olaolu/.nvm/versions/node/v16.7.0/lib/node_modules/term-of-the-day/build/src/wordStore/store.json"
export SPICETIFY_INSTALL="/home/olaolu/spicetify-cli"
export PATH="$SPICETIFY_INSTALL:$PATH"

export TERM="xterm-256color"
export EDITOR="nvim"
export DOTFILES="$HOME/Desktop/olaolu_dev/dotfiles"

export FONT_DIR="$HOME/.local/share/fonts"
export SYS_BAK_DIR="$HOME/sys-backups"

# Actual Aliases
alias findRunningNodeServers="ps -aef | grep node"
alias doesFileExist="does_entity_exist -f File"
alias doesDirExist="does_entity_exist -d Directory"

alias listGlobalNpmPackages="npm -g ls --depth 0"
alias matrix="matrix-rain || cmatrix || echo Please install either matrix-rain from npm or cmatrix"
alias newTmuxSession="tmux new -s"

alias resetTmuxConfig="tmux show -g | sed 's/^/set -g /' > ~/.tmux.conf"
alias checkForUpdates="dnf check-update"
alias cb=clipboard

alias initialPush="git push -u origin"
alias signedCommit="git commit -s"
alias removeDotKeepFiles="find . -name '.keep' -delete"

alias reloadAliases="source ~/.bash_aliases"
alias swag="sudo"
alias editAliases="nv ~/.bash_aliases"

alias tmpmail="~/.tmpmail"
alias listRawVpnLocations="ls /etc/openvpn"
alias listVpnLocations="ls /etc/openvpn | grep tcp | cut -d '.' -f 1 | uniq -u"

alias connectToVPN="~/Desktop/olaolu_dev/dev/surfshark_vpn_cli/connectToSurfsharkVPN.sh"
alias notifyMe="notify"
alias checkAutoUpdatesStatus="systemctl list-timers dnf-automatic-install.timer"

alias loginAsPostgresUser="sudo su - postgres"
alias unlockBitwarden="source ~/Desktop/olaolu_dev/dev/bitwarden-auto-unlock/src/autoUnlockBitwardenVault.sh; bw sync"
alias py="python"

alias pvpn="protonvpn-cli"
alias activatePyVirtEnv="source env/bin/activate"
alias neofetchWithConfig="neofetch --config $HOME/neofetchConfig.conf"

alias cls="colorls --dark"
alias listFlatpakThemes="flatpak search gtk3theme"
alias listUserInstalledRpms="dnf repoquery --userinstalled"

alias lls="logo-ls"
alias listEnabledCoprRepo="dnf copr list --installed"
alias updateNvmToLatest="nvm install node --reinstall-packages-from=$(node -v) && nvm alias default node"

alias open="xdg-open"
alias kernelVersion="uname -r"
alias tmux="TERM=xterm-256color tmux"

alias setSuPasswrd="sudo passwd su"
alias spice="spicetify"
alias sysfetch="fm6000"

alias getDirSize="du -sh"
alias getFileSize="du -h"
alias nv="nvim"

alias z="zoxide"
alias echo="echo -e"
alias tmx="tmux"

alias rc="rustc"
alias dconfBackup="dconf dump / > $SYS_BAK_DIR/dconf-settings-backup.dconf"
alias cronBackup="crontab -l > $SYS_BAK_DIR/crontab-backup.bak"

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias refreshFonts="fc-cache -v"

alias exa="exa --icons"
