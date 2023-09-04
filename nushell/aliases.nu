alias listGlobalNpmPackages = pnpm -g ls
alias checkForUpdates = dnf check-update
alias checkAutoUpdatesStatus = systemctl list-timers dnf-automatic-install.timer

alias :e = nvim
alias :g = git
alias :q = clear
alias :Q = exit

alias py = python3
alias pyV = python3 -V
alias pipV = python -m pip -V

alias cls = colorls --dark
alias lls = logo-ls
# alias z = zoxide

alias spice = spicetify
alias sysfetch = fm6000
alias refreshFonts = fc-cache -v

alias exa = exa --icons
alias bgrep = batgrep
alias bman = batman

alias copy = wl-copy
alias paste = wl-paste
alias diffDirs = diff -qr

alias pvpn = protonvpn-cli
alias pvpnUS = pvpn c -p udp --cc US and pvpn s
alias pvpnR = pvpn d and sleep 3 and pvpnUS

alias hc = ghci
alias lg = lazygit
alias starshipConf = nvim $env.DOTS/starship_prompt/starship.toml

alias ll = ls --all --long
alias vc = code
alias st = speedtest

alias news = ^nushell-news.nu --force
alias searchBw = bw list items --pretty --search
alias tmd = termdown

alias bt = bat -p
alias resetSudoPsswdCache = sudo -k
alias fk = flatpak

alias pm = pnpm
alias pmA = pnpm add
alias pmAD = pnpm add -D
alias pmAG = pnpm add -g

alias updatePnpm = corepack prepare pnpm@latest --activate
alias updateGHC = ghcup tui
alias np = nap

alias gpt = chatgpt
alias se = sudoedit
alias icat = kitty +kitten icat

alias gpg = gpg2
alias hlcR = hacker-laws-cli random
alias updateNvim = nvim +AstroUpdate

alias dev = cd $env.DEV
alias dots = cd $env.DOTS
alias docs = cd $env.XDG_DOCUMENTS_DIR
alias dlds = cd $env.XDG_DOWNLOAD_DIR
