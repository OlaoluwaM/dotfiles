#!/usr/bin/env bash

# Display help message
show_help() {
  echo "Usage: $(basename "$0") [OPTION]"
  echo "Compile SCSS to CSS with optional watch mode."
  echo ""
  echo "Options:"
  echo "  -w, --watch   Watch for changes and recompile automatically"
  echo "  -h, --help    Show this help message and exit"
}

# Check dependencies
check_dependencies() {
  if ! command -v sass &>/dev/null; then
    echo "Error: sass not found"
    exit 1
  fi

  if [[ ! -f "./style.scss" ]]; then
    echo "Error: style.scss not found"
    exit 1
  fi
}

# Function to remove comments
remove_comments() {
  sed -i '/\/\*/,/\*\//d' style.css
  echo "Comments removed from style.css"
}

WATCH_MODE=0

# Parse options
while [[ "$#" -gt 0 ]]; do
  case $1 in
  -w | --watch)
    WATCH_MODE=1
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
done

check_dependencies

# Compile and watch
if [[ "$WATCH_MODE" -eq 1 ]]; then
  echo "Watching for changes..."

  # Trap to clean up on exit
  trap 'echo "Stopping watch mode..."; remove_comments; exit' SIGINT SIGTERM

  sass --watch style.scss style.css
else
  echo "Compiling style.scss..."
  sass style.scss | sed '/\/\*/,/\*\//d' >|style.css
  echo "Compilation complete. Output: style.css"
fi
