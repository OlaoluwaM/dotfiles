#!/bin/bash
# This should be placed in /usr/local/bin
# This is being used by the corresponding udev rule located at '/etc/udev/rules.d/99-manage-nvidia-powerd.rules'
# That rule, '99-manage-nvidia-powerd.rules', references this script when it is located at '/usr/local/bin/'
# These two, this script and the udev rule, exist to turn off the 'nvidia_powerd' service while the system runs on battery power and turn it back on while the system is on AC
# This is important because the 'nvidia_powerd' service works to improve the performance (and I think efficiency) of our nvidia gpu and thus siphons away more power for this purpose.
# While the system is on AC, this is not a problem (hence why it can be on), but when using battery power, this somewhat greatly reduces battery life, which is not ideal

# IMPORTANT: This script and its corresponding udev rule cannot be symlinked and must instead be copied to their required destinations.

SERVICE_NAME="nvidia-powerd"
LOG_TAG="manage_nvidia_powerd"

function log_info() {
	logger -t $LOG_TAG "$1"
}

function log_error() {
	logger -t $LOG_TAG -p user.err "$1"
}

function start_service() {
	if systemctl is-active --quiet $SERVICE_NAME; then
		log_info "$SERVICE_NAME service is already running."
		return
	fi

	log_info "Starting $SERVICE_NAME service..."
	if systemctl start $SERVICE_NAME; then
		log_info "$SERVICE_NAME service started successfully."
	else
		log_error "Failed to start $SERVICE_NAME service."
	fi
}

function stop_service() {
	if ! systemctl is-active --quiet $SERVICE_NAME; then
		log_info "$SERVICE_NAME service has already been stopped."
		return
	fi

	log_info "Stopping $SERVICE_NAME service..."
	if systemctl stop $SERVICE_NAME; then
		log_info "$SERVICE_NAME service stopped successfully."
	else
		log_error "Failed to stop $SERVICE_NAME service."
	fi
}

function is_on_ac_power() {
	acpi -a | grep -q "on-line"
}

log_info "Power source changed. Checking status..."

if is_on_ac_power; then
	log_info "AC power detected."
	start_service
else
	log_info "AC power not detected."
	stop_service
fi
