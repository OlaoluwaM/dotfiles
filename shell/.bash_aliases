#!/usr/bin/env bash

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
  aplay "$alarmSound" &>/dev/null
  notify-send -u normal -t 7000 "$MESSAGE"
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

function backupEntityFromHomeDir() {
  entityToBackup="$1"
  # The below must be a path relative to the $HOME dir
  dirToBackup="$2"

  if  [[ -z "$entityToBackup" || -z "$dirToBackup" ]]; then

      [[ -z "$entityToBackup" ]] && echo "Missing required first arg. What do you want to backup?"
      [[ -z "$dirToBackup" ]] && echo "Missing name of directory to backup"

      return 1
  fi


  echo "Compressing $entityToBackup into tarball"
  echo "Compressed file will be stored at $dirToBackup"

  tar -cvzf "$AUX_BAK_DIR/${entityToBackup}.tar.gz" -C $HOME $dirToBackup
}

function restoreEntityToHomeDir() {
  entityToRestore="$1"

  if [[ -z $entityToRestore ]]; then
    echo "Missing arg, what entity do you wish to restore"
    return 1
  fi

  echo "Restoring $entityToRestore from tarball..."

  tar -xzvf "$AUX_BAK_DIR/${entityToRestore}.tar.gz" -C $HOME
}

function backupWallpapers() {
  $(which node) "$WALLPAPERS_DIR/compressWallpapers.mjs";
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

function unlockBWVault() {
  BW_SESSION=$($HOME/Desktop/olaolu_dev/dev/bitwarden-auto-unlock/src/autoUnlockBitwardenVault.sh)
  [ -z $BW_SESSION ] && return 1
  export BW_SESSION

  echo "Initiating Bitwarden vault sync"
  bw sync
}

function areWallpapersBackedup() {
  echo "Counting current wallpapers: \c"
  wallpaperCount=$(ls $WALLPAPERS_DIR/images | wc -l);
  echo $wallpaperCount

  echo -e "Counting images present in compressed wallpapers tarball file: \c"
  wallpaperTarBallFileCount=$(if [[ -f $WALLPAPERS_DIR/tarball/wallpapers.tar.gz ]]; then bc <<<"$(tar -tf $WALLPAPERS_DIR/tarball/wallpapers.tar.gz | wc -l) - 1"; else echo 0; fi);
  echo $wallpaperTarBallFileCount

  if [[ $wallpaperCount -eq $wallpaperTarBallFileCount ]]; then
      echo "All Backed up!"
  elif [[ $wallpaperCount -lt $wallpaperTarBallFileCount ]]; then
      echo "You need restore your wallpapers from the tarball"
  else
      echo "You need to backup your wallpapers hun!"
  fi
}

function areFontsBackedup() {
  echo "Counting current fonts: \c"
  fontCount=$(ls $FONT_DIR | wc -l);
  echo $fontCount

  echo -e "Counting fonts present in compressed font tarball file: \c"
  fontTarBallCount=$( if [[ -f "$AUX_BAK_DIR/fonts.tar.gz" ]]; then  bc <<<"$(tar -tf $AUX_BAK_DIR/fonts.tar.gz | wc -l) - 1"; else echo 0; fi);
  echo $fontTarBallCount

  if [[ $fontCount -eq $fontTarBallCount ]]; then
      echo "All Backed up!"
  elif [[ $fontCount -lt $fontTarBallCount ]]; then
      echo "You need restore your fonts from the tarball"
  else
      echo "You need to backup your fonts hun!"
  fi
}

# function isEntityBackedup() {
#   backedupEntity="$1"
#   dirToBackup="$2"

#   if  [[ -z "$backedupEntity" || -z "$dirToBackup" ]]; then

#       [[ -z "$backedupEntity" ]] && echo "Missing required first arg. What backup do you want to check?"
#       [[ -z "$dirToBackup" ]] && echo "Missing name of directory related to this backup"

#       return 1
#   fi

#   echo "Counting current $backedupEntity: \c"
#   entityCount=$(ls $dirToBackup | wc -l);
#   echo $entityCount

#   echo -e "Counting $backedupEntity present in compressed $backedupEntity tarball file: \c"
#   entityTarBallCount=$( if [[ -f "$AUX_BAK_DIR/${backedupEntity}.tar.gz" ]]; then  bc <<<"$(tar -tf $AUX_BAK_DIR/${backedupEntity}.tar.gz | wc -l) - 1"; else echo 0; fi);
#   echo $entityTarBallCount

#   if [[ $entityCount -eq $entityTarBallCount ]]; then
#       echo "$backedupEntity are all backed up!"
#   elif [[ $entityCount -lt $entityTarBallCount ]]; then
#       echo "You need restore your $backedupEntity from the tarball"
#   else
#       echo "You need to backup your $backedupEntity hun!"
#   fi
# }

function repoInit() {
  # To create the `main` branch https://stackoverflow.com/questions/9162271/fatal-not-a-valid-object-name-master
  git init;
  touch .gitignore;
  git add .;
  git commit -m "repo init";

  git checkout -b develop;
  git rebase main

  git checkout -b feature;
  git rebase develop
}

# Gotten From https://stackoverflow.com/questions/3964068/zsh-automatically-run-ls
function chpwd() {
    emulate -L zsh
    logo-ls -A || exa --icons -a || ls -A
}

function editPromptConf() {
  SHELL_PROMPT="$PS1";

  if [[ $SHELL_PROMPT == *"starship"* ]]; then
      echo "Opening Starship config..."
      nv $HOME/.config/starship.toml || vi $HOME/.config/starship.toml
  elif [[ $SHELL_PROMPT == *"spaceship"* ]]; then
      echo "Opening Spaceship config..."
      nv $HOME/.zshrc || vi $HOME/.zshrc
  fi
}

# Gotten From https://unix.stackexchange.com/a/282433
function addToPATH() {
  case ":$PATH:" in
    *":$1:"*) :;; # already there
    *) PATH="$PATH:$1";; # or PATH="$PATH:$1"
  esac
}

function fixSpicePermissionIssues() {
  sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
  sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps
}

function runInBg() {
  "$@" > /dev/null 2>&1 &
}

function runInBgAndDisown() {
  "$@" > /dev/null 2>&1 & disown
}

function createPyVirtEnv() {
  currentDir=$(pwd)
  virtualEnvPath="${1:=$currentDir}"

  [ ! -d "$virtualEnvPath" ] && mkdir "$virtualEnvPath"

  echo "layout python" > "$virtualEnvPath/.envrc"
  direnv allow "$virtualEnvPath"

  # Commented out to avoid having two virtual envs in one directory
  # python3 -m venv $virtualEnvPath/env

  cd $virtualEnvPath

  # Update pip version to latest since ensurepip is stuck at 21.1
  python -m pip install --upgrade pip

  # Install common depdendencies
  # Reltive path because we have cd'ed into the target directory
  reqFilePath="./requirements.txt"

  echo "pylint" > "$reqFilePath"
  python3 -m pip install -r "$reqFilePath"

  # Let us know what has been installed
  echo -e "\n"
  python3 -m pip list
}

function backupGHExtensions() {
  gh extension list | awk '{print $3}' > "$DOTFILES/git/gh-extensions.txt"
}

function dejaDupIgnore() {
  nameOfDirToIgnore="*${1:=node_modules}*"
  dirLocation="${2:=$LEARNING}"


  for dirName in $(find $dirLocation -name $nameOfDirToIgnore -type d); do
      targetFilePath="$dirName/.deja-dup-ignore"

      if [[ ! -f "$targetFilePath" ]]; then
          touch "$targetFilePath"
      else
	  rm "$targetFilePath"
      fi

      doesFileExist "$targetFilePath"
  done
}

function addInstalledPackages() {
  if [[ $# -eq 0 ]]; then
    nv "$PACKAGE_LST_FILE"
  else
    # This means we have provided packages to add
    PACKAGES_TO_ADD=$(IFS=$'\n'; echo "$*")
    echo "$PACKAGES_TO_ADD" >> "$PACKAGE_LST_FILE"
  fi
}

function updateGnomeTheme() {
  themeName="${1:=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")}"

  if [[ -z "$themeName" ]]; then
    echo "Please specify the name of the theme"
    return 1
  fi

  themeDir="$HOME/.themes/$themeName"

  if [[ ! -d "$themeDir" ]]; then
    echo "$themeDir does not exist. Make sure the theme name provided corresponds with a dir name in the ~/.themes directory"
    return 1
  fi

  echo -e "Setting flatpak theme..."
  sudo flatpak override --env=GTK_THEME="$themeName"

  echo -e "\nCopying gtk-4.0 contents to ~/.config/gtk-4.0/ dir to theme other more stubborn applications..."
  cp -rt "$HOME/.config/gtk-4.0/" "$themeDir/gtk-4.0/*"

  echo -e "\nCopying gtk-3.0 contents to ~/.config/gtk-3.0/ dir, just in case..."
  cp -rt "$HOME/.config/gtk-3.0/" "$themeDir/gtk-3.0/*"

  echo -e "\nAdding terminal padding once again..."
  cat <<END >> "$HOME/.config/gtk-3.0/gtk.css"

  VteTerminal,
  TerminalScreen,
  vte-terminal {
    padding: 16px;
    -VteTerminal-inner-border: 16px;
  }
END
}

function backupInstalledCrates() {
  cargo install --list | awk '{print $1}' | sed -n '1~2p' > $D_SETUP/common/rust-crates.txt
}


# Env Variables

export ALIASES="$HOME/.bash_aliases"
export NOTI_NSUSER_SOUNDNAME="$HOME/Music/windows-11-sounds/chimes.wav"

export wordStore="/home/olaolu/.nvm/versions/node/v16.7.0/lib/node_modules/term-of-the-day/build/src/wordStore/store.json"
export SPICETIFY_INSTALL="$HOME/spicetify-cli"
export SCRIPTS="$HOME/Desktop/olaolu_dev/scripts"

export TERM="xterm-256color"
export EDITOR="nvim"
export DOTFILES="$HOME/Desktop/olaolu_dev/dotfiles"

export FONT_DIR="$HOME/.local/share/fonts"
export SYS_BAK_DIR="$DOTFILES/system"

export DEV="$HOME/Desktop/olaolu_dev/dev"
export DESIGN="$HOME/Desktop/olaolu_dev/design"
export WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"

export LEARNING="$HOME/Desktop/olaolu_dev/learnings"
export FORGIT_INSTALL_DIR="$HOME/.local/bin"
export AUX_BAK_DIR="$HOME/sys-backups"

export BETTER_DISCORD_CONF_DIR="$HOME/.var/app/com.discordapp.Discord/config/BetterDiscord"
export NVM_AUTOLOAD="1"

# distro setup
export D_SETUP="$DEV/distro-setup"
export ZSH_ALIAS_FINDER_AUTOMATIC=true
export PACKAGE_LST_FILE="$D_SETUP/common/packages.txt"

export DOTS="$DOTFILES"
export C_RPMS="$HOME/Downloads/rpms/"
export NAVI_PATH="$DOTFILES/navi/cheats"

export NAVI_CONFIG="$DOTFILES/navi/config.yaml"


# Aliases

alias findRunningNodeServers="ps -aef | grep node"
alias doesFileExist="does_entity_exist -f File"
alias doesDirExist="does_entity_exist -d Directory"

alias listGlobalNpmPackages="npm -g ls --depth 0"
alias matrix="matrix-rain 2>/dev/null|| cmatrix 2>/dev/null|| echo Please install either matrix-rain from npm or cmatrix" # 2> to keep output clean
alias newTmuxSession="tmux new -s"

alias resetTmuxConfig="tmux show -g | sed 's/^/set -g /' > ~/.tmux.conf"
alias checkForUpdates="dnf check-update"
alias initialPush="git push -u origin"

alias signedCommit="git commit -s"
alias removeDotKeepFiles="find . -name '.keep' -delete"
alias reloadAliases="source ~/.bash_aliases"

alias swag="sudo " # https://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias editAliases="nv ~/.bash_aliases"

alias listRawVpnLocations="ls /etc/openvpn"
alias listVpnLocations="ls /etc/openvpn | grep tcp | cut -d '.' -f 1 | uniq -u"
alias connectToVPN="~/Desktop/olaolu_dev/dev/surfshark_vpn_cli/connectToSurfsharkVPN.sh"

alias notifyMe="notify"
alias checkAutoUpdatesStatus="systemctl list-timers dnf-automatic-install.timer"
alias loginAsPostgresUser="sudo su - postgres"

alias py="python3"
alias pvpn="protonvpn-cli"
alias activatePyVirtEnv="source ./bin/activate 2>/dev/null || source env/bin/activate"

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
alias dconfBackup="dconf dump / > $SYS_BAK_DIR/dconf-settings-backup"

alias cronBackup="crontab -l > $SYS_BAK_DIR/crontab-backup.bak"
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"

alias refreshFonts="fc-cache -v"
alias exa="exa --icons"
alias backupGlobalNpmPkgs="npm -g ls -p --depth 0 | tail -n +2 | awk '!/spaceship-prompt|corepack|npm/' > $DOTFILES/npm/global-npm-pkgs.txt"

alias bgrep="batgrep"
alias bman="batman"
alias toDev="cd $DEV"

alias toDesign="cd $DESIGN"
alias wcb=wl-copy
alias wp=wl-paste

alias toDots="cd $DOTFILES"
alias diffDirs="diff -qr"

alias editCustomizations="nv $SYS_BAK_DIR/customizations.log.txt"
alias ascma="asciinema"

alias dupesInPath="echo $PATH | tr ':' '\n' | sort | uniq -d"
alias toScripts="cd $SCRIPTS"
alias growTree="cbonsai --seed 200 -l -i"

alias ydl="youtube-dl"
alias logout-gnome-force="gnome-session-quit --no-prompt --logout"
alias logout-gnome="gnome-session-quit --logout"

alias toLearning="cd $LEARNING"
alias pyV="python -V"
alias pipV="python -m pip -V"

alias fzf="fzf --color=16"
alias forgit-help="firefox https://github.com/wfxr/forgit"
alias addOSREADME="downloadFile https://gist.githubusercontent.com/OlaoluwaM/baa27f06abe2a209695e2bc3a6757c05/raw/228fc9d48ed33bc8d5eb58d265df40323f7fc61e/README-Fancy.md README.md"

alias pvpnUS="pvpn c -p udp --cc US && pvpn s"
alias backupFonts="backupEntityFromHomeDir 'fonts' $HOME/.local/share/fonts"
alias listFilesInTarball="tar -tf"

alias searchBw="bw list items --pretty --search"
alias sizeOf="du -lh"
alias backupDnfAliases="dnf alias | sed 's/Alias//' > $DOTFILES/system/dnf-alias.txt"

alias gtp="gotop"
alias gnomeBackup="dconf dump /org/gnome/ > $SYS_BAK_DIR/gnome-backup"
alias backupShellExtensionList="ls $HOME/.local/share/gnome-shell/extensions > $SYS_BAK_DIR/gnome-shell-ext.txt"

alias getGnomeTheme="gsettings get org.gnome.desktop.interface gtk-theme | tr -d \"'\""
alias syncGnomeShellEdits="busctl --user call org.gnome.Shell /io/elhan/ExtensionsSync io.elhan.ExtensionsSync save"
alias nd="node-docs"

alias countAllFilesInDir="ls -Rp | grep -v / | sed -r '/^\s*$/d' | tail -n +2 | wc -l"
alias checkGnomeKeyringProcess="ps -aux | grep 'keyring' | head -1"
alias lg="lazygit"

alias installBetterDiscord="betterdiscordctl --d-install flatpak install"
alias fixBetterDiscord="betterdiscordctl --d-install flatpak reinstall"
alias isPostgresRunning="service postgresql status"

alias btp="btop"
alias listAllPyVersions="ls -ls /usr/bin/python*"
alias npo="npm outdated"

alias starshipConf="nvim $DOTS/starship_prompt/starship.toml"
alias rm="trash"
alias cat="bat -p"

alias reload="omz reload"
alias clr="clear"
alias q="cd ~ && clear"

alias sudo="sudo " # https://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias e="$EDITOR"
alias x+="chmod +x"

alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'
alias vsc="code"
