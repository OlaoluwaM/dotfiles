#compdef delta

autoload -U is-at-least

_delta() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" : \
'--blame-code-style=[Style string for the code section of a git blame line]:STYLE:_default' \
'--blame-format=[Format string for git blame commit metadata]:FMT:_default' \
'--blame-palette=[Background colors used for git blame lines (space-separated string)]:COLORS:_default' \
'--blame-separator-format=[Separator between the blame format and the code section of a git blame line]:FMT:_default' \
'--blame-separator-style=[Style string for the blame-separator-format]:STYLE:_default' \
'--blame-timestamp-format=[Format of \`git blame\` timestamp in raw git output received by delta]:FMT:_default' \
'--blame-timestamp-output-format=[Format string for git blame timestamp output]:FMT:_default' \
'--config=[Load the config file at PATH instead of ~/.gitconfig]:PATH:_files' \
'--commit-decoration-style=[Style string for the commit hash decoration]:STYLE:_default' \
'--commit-regex=[Regular expression used to identify the commit line when parsing git output]:REGEX:_default' \
'--commit-style=[Style string for the commit hash line]:STYLE:_default' \
'--default-language=[Default language used for syntax highlighting]:LANG:_default' \
'--detect-dark-light=[Detect whether or not the terminal is dark or light by querying for its colors]:DETECT_DARK_LIGHT:((auto\:"Only query the terminal for its colors if the output is not redirected"
always\:"Always query the terminal for its colors"
never\:"Never query the terminal for its colors"))' \
'-@+[Extra arguments to pass to \`git diff\` when using delta to diff two files]:STRING:_default' \
'--diff-args=[Extra arguments to pass to \`git diff\` when using delta to diff two files]:STRING:_default' \
'--diff-stat-align-width=[Width allocated for file paths in a diff stat section]:N:_default' \
'--features=[Names of delta features to activate (space-separated)]:FEATURES:_default' \
'--file-added-label=[Text to display before an added file path]:STRING:_default' \
'--file-copied-label=[Text to display before a copied file path]:STRING:_default' \
'--file-decoration-style=[Style string for the file decoration]:STYLE:_default' \
'--file-modified-label=[Text to display before a modified file path]:STRING:_default' \
'--file-removed-label=[Text to display before a removed file path]:STRING:_default' \
'--file-renamed-label=[Text to display before a renamed file path]:STRING:_default' \
'--file-style=[Style string for the file section]:STYLE:_default' \
'--file-transformation=[Sed-style command transforming file paths for display]:SED_CMD:_default' \
'--generate-completion=[Print completion file for the given shell]:GENERATE_COMPLETION:(bash elvish fish powershell zsh)' \
'--grep-context-line-style=[Style string for non-matching lines of grep output]:STYLE:_default' \
'--grep-file-style=[Style string for file paths in grep output]:STYLE:_default' \
'--grep-header-decoration-style=[Style string for the header decoration in grep output]:STYLE:_default' \
'--grep-header-file-style=[Style string for the file path part of the header in grep output]:STYLE:_default' \
'--grep-line-number-style=[Style string for line numbers in grep output]:STYLE:_default' \
'--grep-output-type=[Grep output format. Possible values\: "ripgrep" - file name printed once, followed by matching lines within that file, each preceded by a line number. "classic" - file name\:line number, followed by matching line. Default is "ripgrep" if \`rg --json\` format is detected, otherwise "classic"]:OUTPUT_TYPE:(ripgrep classic)' \
'--grep-match-line-style=[Style string for matching lines of grep output]:STYLE:_default' \
'--grep-match-word-style=[Style string for the matching substrings within a matching line of grep output]:STYLE:_default' \
'--grep-separator-symbol=[Separator symbol printed after the file path and line number in grep output]:STRING:_default' \
'--hunk-header-decoration-style=[Style string for the hunk-header decoration]:STYLE:_default' \
'--hunk-header-file-style=[Style string for the file path part of the hunk-header]:STYLE:_default' \
'--hunk-header-line-number-style=[Style string for the line number part of the hunk-header]:STYLE:_default' \
'--hunk-header-style=[Style string for the hunk-header]:STYLE:_default' \
'--hunk-label=[Text to display before a hunk header]:STRING:_default' \
'--hyperlinks-commit-link-format=[Format string for commit hyperlinks (requires --hyperlinks)]:FMT:_default' \
'--hyperlinks-file-link-format=[Format string for file hyperlinks (requires --hyperlinks)]:FMT:_default' \
'--inline-hint-style=[Style string for short inline hint text]:STYLE:_default' \
'--inspect-raw-lines=[Kill-switch for --color-moved support]:true|false:(true false)' \
'--line-buffer-size=[Size of internal line buffer]:N:_default' \
'--line-fill-method=[Line-fill method in side-by-side mode]:STRING:(ansi spaces)' \
'--line-numbers-left-format=[Format string for the left column of line numbers]:FMT:_default' \
'--line-numbers-left-style=[Style string for the left column of line numbers]:STYLE:_default' \
'--line-numbers-minus-style=[Style string for line numbers in the old (minus) version of the file]:STYLE:_default' \
'--line-numbers-plus-style=[Style string for line numbers in the new (plus) version of the file]:STYLE:_default' \
'--line-numbers-right-format=[Format string for the right column of line numbers]:FMT:_default' \
'--line-numbers-right-style=[Style string for the right column of line numbers]:STYLE:_default' \
'--line-numbers-zero-style=[Style string for line numbers in unchanged (zero) lines]:STYLE:_default' \
'--map-styles=[Map styles encountered in raw input to desired output styles]:STYLES_MAP:_default' \
'--max-line-distance=[Maximum line pair distance parameter in within-line diff algorithm]:DIST:_default' \
'--max-syntax-highlighting-length=[Stop syntax highlighting lines after this many characters]:N:_default' \
'--max-line-length=[Truncate lines longer than this]:N:_default' \
'--merge-conflict-begin-symbol=[String marking the beginning of a merge conflict region]:STRING:_default' \
'--merge-conflict-end-symbol=[String marking the end of a merge conflict region]:STRING:_default' \
'--merge-conflict-ours-diff-header-decoration-style=[Style string for the decoration of the header above the '\''ours'\'' merge conflict diff]:STYLE:_default' \
'--merge-conflict-ours-diff-header-style=[Style string for the header above the '\''ours'\'' branch merge conflict diff]:STYLE:_default' \
'--merge-conflict-theirs-diff-header-decoration-style=[Style string for the decoration of the header above the '\''theirs'\'' merge conflict diff]:STYLE:_default' \
'--merge-conflict-theirs-diff-header-style=[Style string for the header above the '\''theirs'\'' branch merge conflict diff]:STYLE:_default' \
'--minus-empty-line-marker-style=[Style string for removed empty line marker]:STYLE:_default' \
'--minus-emph-style=[Style string for emphasized sections of removed lines]:STYLE:_default' \
'--minus-non-emph-style=[Style string for non-emphasized sections of removed lines that have an emphasized section]:STYLE:_default' \
'--minus-style=[Style string for removed lines]:STYLE:_default' \
'--navigate-regex=[Regular expression defining navigation stop points]:REGEX:_default' \
'--pager=[Which pager to use]:CMD:_default' \
'--paging=[Whether to use a pager when displaying output]:auto|always|never:(auto always never)' \
'--plus-emph-style=[Style string for emphasized sections of added lines]:STYLE:_default' \
'--plus-empty-line-marker-style=[Style string for added empty line marker]:STYLE:_default' \
'--plus-non-emph-style=[Style string for non-emphasized sections of added lines that have an emphasized section]:STYLE:_default' \
'--plus-style=[Style string for added lines]:STYLE:_default' \
'--right-arrow=[Text to display with a changed file path]:STRING:_default' \
'--syntax-theme=[The syntax-highlighting theme to use]:SYNTAX_THEME:_default' \
'--tabs=[The number of spaces to replace tab characters with]:N:_default' \
'--true-color=[Whether to emit 24-bit ("true color") RGB color codes]:auto|always|never:(auto always never)' \
'--whitespace-error-style=[Style string for whitespace errors]:STYLE:_default' \
'-w+[The width of underline/overline decorations]:N:_default' \
'--width=[The width of underline/overline decorations]:N:_default' \
'--word-diff-regex=[Regular expression defining a '\''word'\'' in within-line diff algorithm]:REGEX:_default' \
'--wrap-left-symbol=[End-of-line wrapped content symbol (left-aligned)]:STRING:_default' \
'--wrap-max-lines=[How often a line should be wrapped if it does not fit]:N:_default' \
'--wrap-right-percent=[Threshold for right-aligning wrapped content]:PERCENT:_default' \
'--wrap-right-prefix-symbol=[Pre-wrapped content symbol (right-aligned)]:STRING:_default' \
'--wrap-right-symbol=[End-of-line wrapped content symbol (right-aligned)]:STRING:_default' \
'--zero-style=[Style string for unchanged lines]:STYLE:_default' \
'--24-bit-color=[Deprecated\: use --true-color]:auto|always|never:(auto always never)' \
'--color-only[Do not alter the input structurally in any way]' \
'--dark[Use default colors appropriate for a dark terminal background]' \
'--diff-highlight[Emulate diff-highlight]' \
'--diff-so-fancy[Emulate diff-so-fancy]' \
'--hyperlinks[Render commit hashes, file names, and line numbers as hyperlinks]' \
'--keep-plus-minus-markers[Prefix added/removed lines with a +/- character, as git does]' \
'--light[Use default colors appropriate for a light terminal background]' \
'-n[Display line numbers next to the diff]' \
'--line-numbers[Display line numbers next to the diff]' \
'--list-languages[List supported languages and associated file extensions]' \
'--list-syntax-themes[List available syntax-highlighting color themes]' \
'--navigate[Activate diff navigation]' \
'--no-gitconfig[Do not read any settings from git config]' \
'--parse-ansi[Display ANSI color escape sequences in human-readable form]' \
'--raw[Do not alter the input in any way]' \
'--relative-paths[Output all file paths relative to the current directory]' \
'--show-colors[Show available named colors]' \
'--show-config[Display the active values for all Delta options]' \
'--show-syntax-themes[Show example diff for available syntax-highlighting themes]' \
'--show-themes[Show example diff for available delta themes]' \
'-s[Display diffs in side-by-side layout]' \
'--side-by-side[Display diffs in side-by-side layout]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
'::minus_file -- First file to be compared when delta is being used to diff two files:_files' \
'::plus_file -- Second file to be compared when delta is being used to diff two files:_files' \
&& ret=0
}

(( $+functions[_delta_commands] )) ||
_delta_commands() {
    local commands; commands=()
    _describe -t commands 'delta commands' commands "$@"
}

if [ "$funcstack[1]" = "_delta" ]; then
    _delta "$@"
else
    compdef _delta delta
fi
