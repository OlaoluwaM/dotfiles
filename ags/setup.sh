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

function in_array() {
    local element
    for element in "${@:1:$(($# - 1))}"; do
        if [[ $element == "${!#}" ]]; then
            return 0
        fi
    done
    return 1
}

target_dir="$HOME/.config/ags"

# Function for the link command
link() {
    echo "Linking configs..."
    if [[ -d "$target_dir" ]]; then
        rm -rf "$target_dir"
    fi

    mkdir -p "$target_dir"
    files_to_omit=("./setup.sh" "./package.json" "./.gitignore" "./.stylelintrc.yml" "./package-lock.json")

    for file in ./*; do
        if [[ "$file" =~ "node_modules" ]]; then
            echo "Skipping files in .cosine and node_modules directories"
            continue
        fi

        if [[ "${files_to_omit[*]}" =~ ${file} ]]; then
            echo "Skipping $file"
            continue
        fi

        real_path=$(realpath "$file")
        cp -sva "$real_path" "$target_dir"
    done

    echo "Done"
}

# Function for the unlink command
unlink() {
    echo "Unlinking..."
    if [[ -d "$directory" ]]; then
        rm -rf "$target_dir"
    else
        echo "The target directory for these config files ($target_dir) does not exist."
        echo "Doing nothing"
    fi
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
