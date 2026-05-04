#!/bin/bash

# This should be copied into the /usr/local/bin directory first, then corresponding udev custom rule file should be copied into its appropriate position (/etc/udev/rules.d/)
# This is being used by the corresponding udev rule located at '/etc/udev/rules.d/98-auto-power-profile-change.rules'
# That rule, '98-auto-power-profile-change.rules', references this script and two others when it is located at '/usr/local/bin/' hence why they have have to be copied first
# The purpose being these scripts is to automatically switch the tuned power profile to an appropriate profile when the system power state changes from AC to battery to low battery.
# This script specifically switches the tuned profile to 'balanced-battery' when the system is on battery power.
# Initially, this functionality was covered for us by asusctl but since we no longer use the custom rog kernel, we need to handle this ourselves.

# IMPORTANT: This script and its corresponding udev rule cannot be symlinked and must instead be copied to their required destinations.
# Udev attributes are passed as arguments into this script: https://www.linuxquestions.org/questions/programming-9/udev-rules-how-to-pass-attrs%7B%2A%7D-values-to-the-run-command-834307/#google_vignette

LOG_TAG="switch_power_profile"
BATTERY_LEVEL="$1"
BATTERY_STATUS="$2"

function log_info() {
	logger -t $LOG_TAG "$1"
}

function log_error() {
	logger -t $LOG_TAG -p user.err "$1"
}

function notify_user() {
	local user uid
	user=$(logname 2>/dev/null || who | awk 'NR==1{print $1}')
	uid=$(id -u "$user")
	sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" notify-send -a "Power Profile" "$@"
}

function switch_to_tuned_profile() {
	local target_profile current_profile
	target_profile="$1"
	current_profile=$(tuned-adm active)

	if [[ "$current_profile" == *"$target_profile"* ]]; then
		log_info "Power profile already set to '$target_profile'"
		return 0
	fi

	if tuned-adm profile "$target_profile"; then
		log_info "Switched to '$target_profile' profile successfully."
		notify_user "Switched to '$target_profile'"
	else
		log_error "Failed to switch to '$target_profile' profile. Profile may not exist or there was some other error."
	fi
}

function switch_power_profile() {
	log_info "Received battery status: $BATTERY_STATUS, battery level: $BATTERY_LEVEL%"
	if [[ "$BATTERY_STATUS" == "Charging" ]]; then
		log_info "Battery is charging, switching to 'throughput-performance' profile."
		switch_to_tuned_profile throughput-performance
		return
	fi

	if [[ "$BATTERY_LEVEL" -le 35 ]]; then
		log_info "Battery level is low, switching to 'powersave' profile."
		switch_to_tuned_profile powersave
	elif [[ "$BATTERY_LEVEL" -le 65 ]]; then
		log_info "Battery level is moderate, switching to 'balanced-battery' profile."
		switch_to_tuned_profile balanced-battery
	else
		log_info "Battery level is above 65%, switching to 'performance' profile."
		switch_to_tuned_profile throughput-performance
	fi
}

switch_power_profile
