#!/usr/bin/env bash

# Needs to be run in background as otherwise something overrides it
/usr/libexec/polkit-gnome-authentication-agent-1 &
gnome-keyring-daemon -s -c=gpg,pkcs11,secrets,ssh &
#gnome-keyring-daemon -r -c=gpg,pkcs11,secrets,ssh &
