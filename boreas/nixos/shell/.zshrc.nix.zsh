# Replica of .zshrc, but for NixOS. We want OMZ to be handled by home-manager so we remove it's config from here
# Using relative paths since this file won't be moved be symlinked to $HOME, but will be sourced from here

# Must be before anything else since some of the other files depend on these env vars

### These need to be in this order exactly 
if [[ -f "./env.zsh" ]]; then
	source "./env.zsh"
fi

if [[ -f "./functions.zsh" ]]; then
	source "./functions.zsh"
fi

if [[ -f "./bindings.zsh" ]]; then
	source "./bindings.zsh"
fi
####

if [[ -f "./scripts/smartdots.zsh" ]]; then
	source "./scripts/smartdots.zsh"
fi

if [[ -f "./scripts/augment-path-var.sh" ]]; then
	source "./scripts/augment-path-var.sh"
fi

if [[ -f "./scripts/linux-tty-catppuccin-colors.sh" ]]; then
	source "./scripts/linux-tty-catppuccin-colors.sh"
fi

# Do not override files using `>`, but it's still possible using `>|`
set -o noclobber

# To allow us omit commands prefix with a space from shell history
setopt HIST_IGNORE_SPACE

# For vscode shell integrations
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

# Atuin (https://github.com/ellie/atuin)
if command -v atuin &>/dev/null; then
	eval "$(atuin init zsh)"
fi

fpath=($fpath "/home/olaolu/.zfunctions")
fpath=($fpath "/home/olaolu/.zfunctions")

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

# enable the GPG agent to avoid having to type the secret key's password every time (https://withblue.ink/2020/05/17/how-and-why-to-sign-git-commits.html#cryptographic-signatures-and-gpg)
#if command -v gpgconf &>/dev/null; then
#	gpgconf --launch gpg-agent
#fi

# Load zsh completions for executables if at least one exists
# https://docs.haskellstack.org/en/stable/shell_autocompletion/
# https://github.com/chubin/cheat.sh?tab=readme-ov-file#zsh-tab-completion
# https://dandavison.github.io/delta/tips-and-tricks/shell-completion.html
if [[ -d "$XDG_CONFIG_HOME/zsh/completions/" ]] && [[ -n "$(ls -A "$XDG_CONFIG_HOME/zsh/completions/")" ]]; then
	fpath=($HOME/.config/zsh/completions $fpath)
fi

if command -v batpipe &>/dev/null; then
	eval "$(batpipe)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#https://docs.atuin.sh/reference/gen-completions/
[ -s "$DOTS/shell/completions/_atuin" ] && source "$DOTS/shell/completions/_atuin"
[ -s "$DOTS/shell/completions/navi.zsh" ] && source "$DOTS/shell/completions/navi.zsh"
[ -s "$DOTS/shell/completions/_rip" ] && source "$DOTS/shell/completions/_rip"

[ -f "/home/olaolu/.ghcup/env" ] && . "/home/olaolu/.ghcup/env" # ghcup
