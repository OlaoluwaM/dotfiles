#!/usr/bin/env bash

# Enable extended globbing
shopt -s extglob

if ! command -v rip &>/dev/null; then
    echo "rip could not be found. Please install rip"
    echo "You can install it from here https://github.com/nivekuil/rip"
    exit 1
fi

# Function to display help message
show_help() {
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  link      Links all config files in this directory"
    echo "  unlink    Unlinks all config files in this directory"
    echo "Options:"
    echo "  -h, --help    Display this help message."
    echo ""
    echo "Note that it would be best to run this script within the directory it's defined in"
    echo "Also note that you will be prompted before any deletes are performed, for safety"
    echo "The rip (https://github.com/nivekuil/rip) utility is needed for this script to work"
}

target_dir="$HOME/.config/ulauncher"

# Function for the unlink command
unlink() {
    if [[ -d "$target_dir" ]]; then

        if [[ "$target_dir" == "$HOME/.config/" ]] || [[ "$target_dir" == "$HOME/.config" ]]; then
            echo "No!!!!!!!!! You cannot delete ~/.config"
            echo "Bad boy"
            exit 1
        fi

        echo "Sending $target_dir to the graveyard..."
        rip -i "$target_dir"
        echo "Done"
    else
        echo "The target directory for these config files ($target_dir) does not exist."
        echo "Doing nothing"
    fi
}

# Function for the link command
link() {
    echo "Linking dots dir to $target_dir..."

    unlink

    ln -svf $DOTS/ulauncher "$target_dir"

    echo "Done"
}

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    echo "Error: No command provided. Use -h or --help for usage information."
    exit 1
fi

# Parse command and options
command=$1
shift

while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
        show_help
        exit 0
        ;;
    *)
        echo "Error: Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
    shift
done

# Execute the appropriate command
case "$command" in
link)
    link
    ;;
unlink)
    unlink
    ;;
*)
    echo "Error: Unknown command: $command"
    show_help
    exit 1
    ;;
esac

exit 0