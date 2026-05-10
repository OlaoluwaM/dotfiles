# Replica of .zshrc, but for NixOS. We want OMZ to be handled by home-manager so we remove its config from here. This file will be sourced by .zshrc before OMZ is loaded

zshrc_source="${ZDOTDIR:-$HOME}/.zshrc"
zshrc_dir="$(dirname -- "$(realpath -- "$zshrc_source")")"

if [[ -f "$HOME/.shell-env" ]]; then
	source "$HOME/.shell-env"
fi

if [[ -f "$zshrc_dir/scripts/smartdots.zsh" ]]; then
	source "$zshrc_dir/scripts/smartdots.zsh"
fi

if [[ -f "$zshrc_dir/scripts/augment-path-var.sh" ]]; then
	source "$zshrc_dir/scripts/augment-path-var.sh"
fi

if [[ -f "$zshrc_dir/scripts/linux-tty-catppuccin-colors.sh" ]]; then
	source "$zshrc_dir/scripts/linux-tty-catppuccin-colors.sh"
fi

# Do not override files using `>`, but it's still possible using `>|`
set -o noclobber

# To allow us omit commands prefix with a space from shell history
setopt HIST_IGNORE_SPACE

# For vscode shell integrations
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

[[ -d "$HOME/.zfunctions" ]] && fpath=("$HOME/.zfunctions" $fpath)

# Atuin (https://github.com/ellie/atuin)
if command -v atuin &>/dev/null; then
	eval "$(atuin init zsh)"
fi

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Rust Cargo
case ":$PATH:" in
*":$HOME/.cargo/bin:"*) ;;
*) export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# Setup Starship ZSH prompt (https://github.com/starship/starship)
if command -v starship &>/dev/null; then
	eval "$(starship init zsh)"
fi

# Setup Navi widget (not a shell completion) https://github.com/denisidoro/navi/tree/master/docs/widgets
if command -v navi &>/dev/null; then
	eval "$(navi widget zsh)"
fi

# Load zsh completions for executables if at least one exists
# https://unix.stackexchange.com/questions/33255/how-to-define-and-load-your-own-shell-function-in-zsh
if [[ -d "$zshrc_dir/completions/" ]]; then
	fpath=($zshrc_dir/completions $fpath)
fi

if command -v batpipe &>/dev/null; then
	eval "$(batpipe)"
fi

[ -f "/home/olaolu/.ghcup/env" ] && . "/home/olaolu/.ghcup/env" # ghcup
