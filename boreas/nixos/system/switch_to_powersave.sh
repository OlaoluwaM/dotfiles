#!/bin/bash

# This should be copied into the /usr/local/bin directory first, then corresponding udev custom rule file should be copied into its appropriate position (/etc/udev/rules.d/)
# This is being used by the corresponding udev rule located at '/etc/udev/rules.d/98-auto-power-profile-change.rules'
# That rule, '98-auto-power-profile-change.rules', references this script and two others when it is located at '/usr/local/bin/' hence why they have have to be copied first
# The purpose being these scripts is to automatically switch the tuned power profile to an appropriate profile when the system power state changes from AC to battery to low battery.
# This script specifically switches the tuned profile to 'powersave' when the system is on low battery power.
# Initially, this functionality was covered for us by asusctl but since we no longer use the custom rog kernel, we need to handle this ourselves.

# IMPORTANT: This script and its corresponding udev rule cannot be symlinked and must instead be copied to their required destinations.

LOG_TAG="switch_to_powersave"

function log_info() {
    logger -t $LOG_TAG "$1"
}

function log_error() {
    logger -t $LOG_TAG -p user.err "$1"
}

function switch_to_powersave_profile() {
    if tuned-adm profile powersave; then
        log_info "Switched to 'powersave' profile successfully."
    else
        log_error "Failed to switch to 'powersave' profile."
    fi
}

current_profile=$(tuned-adm active)

if [[ "$current_profile" == *"powersave"* ]]; then
    log_info "Power profile already set to 'powersave'"
else
    log_info "Switching to 'powersave' profile..."
    switch_to_powersave_profile
fi
