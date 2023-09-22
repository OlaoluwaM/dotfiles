# Nushell Environment Config File
#
# version = "0.84.0"

# Will keep the default stuff for now
############################################### Default stuff starts here ################################################

def create_left_prompt [] {
    mut home = ""
    try {
        if $nu.os-info.name == "windows" {
            $home = $env.USERPROFILE
        } else {
            $home = $env.HOME
        }
    }

    let dir = ([
        ($env.PWD | str substring 0..($home | str length) | str replace $home "~"),
        ($env.PWD | str substring ($home | str length)..)
    ] | str join)

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)/($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%Y/%m/%d %r')
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# $env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
#$env.ENV_CONVERSIONS = {
#    "PATH": {
#        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
#        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
#    }
#    "Path": {
#        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
#        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
#    }
#}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]
############################################### Default stuff stops here ################################################

def-env _set_manpager [pager: string] {
    $env.MANPAGER = (match $pager {
        "bat" => "sh -c 'col -bx | bat -l man -p'",
        "vim" => '/bin/bash -c "vim -MRn -c \"set buftype=nofile showtabline=0 ft=man ts=8 nomod nolist norelativenumber nonu noma\" -c \"normal L\" -c \"nmap q :qa<CR>\"</dev/tty <(col -b)"',
        "nvim" => "nvim -c 'set ft=man' -",
        _ => {
            print $"unknown manpage '($pager)', defaulting to prettier `less`"
            $env.LESS_TERMCAP_mb = (tput bold; tput setaf 2)  # green
            $env.LESS_TERMCAP_md = (tput bold; tput setaf 2)  # green
            $env.LESS_TERMCAP_so = (tput bold; tput rev; tput setaf 3)  # yellow
            $env.LESS_TERMCAP_se = (tput smul; tput sgr0)
            $env.LESS_TERMCAP_us = (tput bold; tput bold; tput setaf 1)  # red
            $env.LESS_TERMCAP_me = (tput sgr0)
         }
    })
}

_set_manpager "bat"

export-env {
    let esep_list_converter = {
        from_string: { |s| $s | split row (char esep) }
        to_string: { |v| $v | str join (char esep) }
    }

    $env.ENV_CONVERSIONS = {
        XDG_DATA_DIRS: $esep_list_converter
        TERMINFO_DIRS: $esep_list_converter

        "PATH": {
            from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
            to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
        }
        "Path": {
            from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
            to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
        }
    }
}

export-env { load-env {
    XDG_DATA_HOME: ($env.HOME | path join ".local" "share")
    XDG_CONFIG_HOME: ($env.HOME | path join ".config")
    XDG_STATE_HOME: ($env.HOME | path join ".local" "state")
    XDG_CACHE_HOME: ($env.HOME | path join ".cache")
    XDG_DESKTOP: ($env.HOME | path join "Desktop")
    XDG_DOCUMENTS_DIR: ($env.HOME | path join "Documents")
    XDG_DOWNLOAD_DIR: ($env.HOME | path join "Downloads")
    XDG_MUSIC_DIR: ($env.HOME | path join "Music")
    XDG_PICTURES_DIR: ($env.HOME | path join "Pictures")
    XDG_VIDEOS_DIR: ($env.HOME | path join "Videos")
}}

$env.TERMINFO_DIRS = (
    [
        ($env.XDG_DATA_HOME | path join "terminfo")
        "/usr/share/terminfo"
    ]
    | str join ":"
)

# Program path variables
export-env { load-env {
    NUPM_HOME: ($env.XDG_DATA_HOME | path join "nupm")
    STARSHIP_CACHE: ($env.XDG_CACHE_HOME | path join "starship")
    TERMINFO: ($env.XDG_DATA_HOME | path join "terminfo")
    SPICETIFY: ($env.HOME | path join ".spicetify")
    GHCUP: ($env.HOME | path join ".ghcup")
    BUN_PATH: ($env.HOME | path join ".bun")
    MY_HOME: ($env.XDG_DESKTOP | path join "olaolu_dev")
    FONT_DIR: ($env.XDG_DATA_HOME | path join "fonts")
    CUSTOM_BIN_DIR: ($env.HOME | path join ".local" "bin")
}}

$env.BROWSER = "firefox"
$env.TERMINAL = "kitty"
$env.EDITOR = 'nvim'
$env.VISUAL = $env.EDITOR

$env.FZF_DEFAULT_OPTS = "
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"

$env.PATH = (
    $env.PATH
        | split row (char esep)
        | prepend $env.SPICETIFY
        | prepend $env.CUSTOM_BIN_DIR
        | prepend ($env.HOME | path join "bin")
        | prepend ($env.GHCUP | path join "bin")
        | prepend ($env.BUN_PATH | path join "bin")
        | prepend ($env.NUPM_HOME | path join "bin")
        | prepend ($env.XDG_DATA_HOME | path join "pnpm") # For programs installed via pnpm
        | prepend ($env.HOME | path join ".cabal" "bin") # For using cabal library binaries...I think
        | prepend ($env.HOME | path join ".cargo" "bin") # For binaries installed via cargo
        | prepend ($env.HOME | path join "go" "bin") # For go binaries
        | prepend /usr/bin
        | prepend /usr/sbin
        | prepend /usr/local/sbin
        | prepend /usr/local/bin
        | append /usr/lib64/ccache
        | uniq
)

if not (which fnm | is-empty) {
    ^fnm env --json | from json | load-env

    $env.PATH = (
        $env.PATH
            | split row (char esep)
            | prepend ($env.FNM_MULTISHELL_PATH | path join "bin")
    )
}

$env.NU_LIB_DIRS = [
    $env.NUPM_HOME
    $env.STARSHIP_CACHE
]

export-env {
    $env.DEV = ($env.MY_HOME | path join "dev")
    $env.DOTS = ($env.MY_HOME | path join "dotfiles")
    $env.DISTRO_SETUP = ($env.DEV | path join "distro-setup")

    load-env {
        DEV: $env.DEV
        DOTS: $env.DOTS
        DISTRO_SETUP: $env.DISTRO_SETUP
        CUSTOM_BIN_DIR: $env.CUSTOM_BIN_DIR

        NAVI_PATH: ($env.DOTS | path join "navi" "cheats")
        NAVI_CONFIG: ($env.DOTS | path join "navi" "config.yaml")
        ASTRONVIM_CONFIG: ($env.XDG_CONFIG_HOME | path join "nvim" "lua" "user" "init.lua")

        _ZO_DATA_DIR: ($env.DOTS | path join "zoxide")
        THEMES_DIR: ($env.HOME | path join ".themes")
        SYS_BAK_DIR: ($env.DOTS | path join "system")

        WALLPAPER_DIR: ($env.XDG_PICTURES_DIR | path join "Wallpapers")
        SPICETIFY_INSTALL: ($env.HOME | path join "spicetify-cli")
        PACKAGE_LST_FILE: ($env.DISTRO_SETUP | path join "src" "common" "assets" "packages.txt")

        NAP_CONFIG: ($env.DOTS | path join "nap" "config.yaml")
        ATUIN_CONFIG_DIR: ($env.DOTS | path join "atuin")
        TEALDEER_CONFIG_DIR: ($env.DOTS | path join "tldr")

        ATUIN_NOBIND: true
        ATUIN_NU_DIR: ($env.XDG_DATA_HOME | path join "atuin")
        FNM_COREPACK_ENABLED: true
    }
}

$env.GPG_TTY = (tty)

# Zoixide Integration
zoxide init nushell --cmd z | save -f ~/.zoxide.nu

# Atuin Integration
mkdir $env.ATUIN_NU_DIR
atuin init nu --disable-up-arrow | save -f ($env.ATUIN_NU_DIR | path join "init.nu")

# Carapace Integration
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

# Starship prompt setup
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
