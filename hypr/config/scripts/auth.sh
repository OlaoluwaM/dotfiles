#!/usr/bin/env bash

# Needs to be run in background as otherwise something overrides it
/usr/libexec/polkit-gnome-authentication-agent-1 &
gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh &
