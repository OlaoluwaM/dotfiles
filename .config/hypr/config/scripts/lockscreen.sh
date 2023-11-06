#!/usr/bin/env bash

#  ___    _ _      _   _
# |_ _|__| | | ___| |_(_)_ __ ___   ___
#  | |/ _` | |/ _ \ __| | '_ ` _ \ / _ \
#  | | (_| | |  __/ |_| | | | | | |  __/
# |___\__,_|_|\___|\__|_|_| |_| |_|\___|
#
#
# -----------------------------------------------------

# Swayidle will lock the screen after 300 seconds (~5 minutes) of inactivity
# After 10 minutes (600 seconds) it will switch of the display
# If activity resumes it will switch the display back on
# Before the device goes to sleep it will lock the screen

if [ -f "/usr/bin/swayidle" ]; then
  echo "swayidle is installed."
  swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'hyprctl dispatch dpms off' \
      resume 'hyprctl dispatch dpms on' \
    before-sleep 'swaylock -f' 
else
  echo "swayidle not installed."
fi
