#!/usr/bin/env bash

LAYOUT="$XDG_CONFIG_HOME/wlogout/layout"
STYLE="$XDG_CONFIG_HOME/wlogout/style.css"

if [[ ! $(pidof wlogout) ]]; then
    wlogout
else
    pkill wlogout
fi
