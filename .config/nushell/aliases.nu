alias listGlobalNpmPackages = pnpm -g ls
alias checkForUpdates = dnf check-update
alias checkAutoUpdatesStatus = systemctl list-timers dnf-automatic-install.timer

alias :e = nvim
alias :q = cd $env.HOME; clear
alias :Q = exit

alias py = python3
alias pyV = python3 -V
alias pipV = python -m pip -V

alias lls = logo-ls
alias :vc = code .

alias spice = spicetify
alias sysfetch = fm6000
alias refreshFonts = fc-cache -v

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

alias editAliases = nvim $"($env.DOTS)/nushell/aliases.nu"
alias sysFetch = fm6000
alias editNuConf = nvim $nu.config-path

alias editCustomCommands = nvim $"($nu.default-config-dir)/custom-commands.nu"
alias editNuEnvVars = nvim $nu.env-path
alias bgrep = batgrep

alias bman = batman
alias nuDots = cd ($env.DOTS | path join "nushell")
alias ga = git add

alias gcmsg = git commit -m
alias reload = exec nu
alias g = git

alias checkForCrateUpdates = cargo-install-update install-update --list
alias bunR = bun repl
alias checkRecentlyUpdatedPackages = dnf history info

alias cw = change-wallpaper
