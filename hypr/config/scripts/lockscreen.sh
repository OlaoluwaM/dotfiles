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

timeswaylock=400
timeoff=660

if [ -f "/usr/bin/swayidle" ]; then
  echo "swayidle is installed."
  swayidle -w timeout $timeswaylock 'swaylock -f' timeout $timeoff 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f' lock 'hyprctl dispatch exit none; logout'
else
  echo "swayidle not installed."
fi
