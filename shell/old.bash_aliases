alias newTmuxSession="tmux new -s"
alias listRawVpnLocations="ls /etc/openvpn"
alias dconfBackup="dconf dump / > $SYS_BAK_DIR/dconf-settings-backup"
alias listVpnLocations="ls /etc/openvpn | grep tcp | cut -d '.' -f 1 | uniq -u"
alias gnomeBackup="dconf dump /org/gnome/ > $SYS_BAK_DIR/gnome-backup"
alias resetTmuxConfig="tmux show -g | sed 's/^/set -g /' > ~/.tmux.conf"

# Old env variables
export FORGIT_INSTALL_DIR="$HOME/.local/bin"
