#!/usr/bin/env bash

LAYOUT="$HOME/.config/wlogout/layout"
STYLE="$HOME/.config/wlogout/style.css"

if [[ ! $(pidof wlogout) ]]; then
    wlogout
else
    pkill wlogout
fi
