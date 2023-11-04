#!/usr/bin/env bash

# Enable extended globbing
shopt -s extglob

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
}

curr_dir="$DOTS/emptty"

# Function for the link command
link() {
    echo "Linking..."
    ln -svf "$curr_dir/emptty.1" "$CUSTOM_MAN_PATH/man1/"
    ln -svf "$curr_dir/.emptty" "$HOME"

    sudo cp -vf "$curr_dir/conf" "/etc/emptty/"
    sudo cp -vf "$curr_dir/motd-gen.sh" "/etc/emptty/"
    echo "Done"
}

# Function for the unlink command
unlink() {
    echo "Unlinking..."
    rm -v "$CUSTOM_MAN_PATH/man1/emptty.1"
    rm -v "$HOME/.emptty"

    sudo rm -v "/etc/emptty/conf"
    sudo rm -v "/etc/emptty/motd-gen.sh"
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
        -h|--help)
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
