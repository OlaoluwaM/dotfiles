#!/bin/bash

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
