#!/usr/bin/env bash

#  ___    _ _      _   _
# |_ _|__| | | ___| |_(_)_ __ ___   ___
#  | |/ _` | |/ _ \ __| | '_ ` _ \ / _ \
#  | | (_| | |  __/ |_| | | | | | |  __/
# |___\__,_|_|\___|\__|_|_| |_| |_|\___|
#
#
# by Stephan Raabe (2023)
# https://gitlab.com/stephan-raabe/dotfiles/-/blob/main/scripts/lockscreentime.sh
# -----------------------------------------------------

if [ -f "/usr/bin/swayidle" ]; then
  echo "swayidle is installed."
  swayidle -w timeout 300 '$DOTS/hypr/config/scripts/brightness.sh off' resume '$DOTS/hypr/config/scripts/brightness.sh off' timeout 450 'swaylock -f' timeout 660 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 900 'systemctl suspend'
else
  echo "swayidle not installed."
fi
